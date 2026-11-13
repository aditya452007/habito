import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:streak/services/laptop_activity_store.dart';

// Win32 Structures for 64-bit Windows
final class LASTINPUTINFO extends Struct {
  @Uint32()
  external int cbSize;

  @Uint32()
  external int dwTime;
}

typedef _GetForegroundWindowNative = IntPtr Function();
typedef _GetForegroundWindowDart = int Function();

typedef _GetWindowThreadProcessIdNative = Uint32 Function(
  IntPtr hWnd,
  Pointer<Uint32> lpdwProcessId,
);
typedef _GetWindowThreadProcessIdDart = int Function(
  int hWnd,
  Pointer<Uint32> lpdwProcessId,
);

typedef _GetLastInputInfoNative = Int32 Function(Pointer<LASTINPUTINFO> plii);
typedef _GetLastInputInfoDart = int Function(Pointer<LASTINPUTINFO> plii);

typedef _GetTickCount64Native = Uint64 Function();
typedef _GetTickCount64Dart = int Function();

typedef _OpenProcessNative = IntPtr Function(
  Uint32 dwDesiredAccess,
  Int32 bInheritHandle,
  Uint32 dwProcessId,
);
typedef _OpenProcessDart = int Function(
  int dwDesiredAccess,
  int bInheritHandle,
  int dwProcessId,
);

typedef _QueryFullProcessImageNameWNative = Int32 Function(
  IntPtr hProcess,
  Uint32 dwFlags,
  Pointer<Utf16> lpExeName,
  Pointer<Uint32> lpdwSize,
);
typedef _QueryFullProcessImageNameWDart = int Function(
  int hProcess,
  int dwFlags,
  Pointer<Utf16> lpExeName,
  Pointer<Uint32> lpdwSize,
);

typedef _CloseHandleNative = Int32 Function(IntPtr hObject);
typedef _CloseHandleDart = int Function(int hObject);

typedef _GetCurrentProcessNative = IntPtr Function();
typedef _GetCurrentProcessDart = int Function();

typedef _SetProcessWorkingSetSizeNative = Int32 Function(
  IntPtr hProcess,
  IntPtr dwMinimumWorkingSetSize,
  IntPtr dwMaximumWorkingSetSize,
);
typedef _SetProcessWorkingSetSizeDart = int Function(
  int hProcess,
  int dwMinimumWorkingSetSize,
  int dwMaximumWorkingSetSize,
);

class WindowsActivityTracker {
  WindowsActivityTracker._();

  static const int _sampleIntervalSeconds = 15;
  static const int _processQueryLimitedInfo = 0x1000;

  static Timer? _trackerTimer;
  static Timer? _flushTimer;
  static bool _initialized = false;
  static bool _available = false;

  // FFI bindings
  static _GetForegroundWindowDart? _getForegroundWindow;
  static _GetWindowThreadProcessIdDart? _getWindowThreadProcessId;
  static _GetLastInputInfoDart? _getLastInputInfo;
  static _GetTickCount64Dart? _getTickCount64;
  static _OpenProcessDart? _openProcess;
  static _QueryFullProcessImageNameWDart? _queryFullProcessImageNameW;
  static _CloseHandleDart? _closeHandle;
  static _GetCurrentProcessDart? _getCurrentProcess;
  static _SetProcessWorkingSetSizeDart? _setProcessWorkingSetSize;

  static bool get isSupported => Platform.isWindows;
  static bool get isRunning => _trackerTimer != null;

  static void initialize() {
    if (_initialized || !Platform.isWindows) return;
    _initialized = true;

    try {
      final user32 = DynamicLibrary.open('user32.dll');
      final kernel32 = DynamicLibrary.open('kernel32.dll');

      _getForegroundWindow = user32
          .lookupFunction<_GetForegroundWindowNative, _GetForegroundWindowDart>(
        'GetForegroundWindow',
      );
      _getWindowThreadProcessId = user32.lookupFunction<
          _GetWindowThreadProcessIdNative, _GetWindowThreadProcessIdDart>(
        'GetWindowThreadProcessId',
      );
      _getLastInputInfo = user32
          .lookupFunction<_GetLastInputInfoNative, _GetLastInputInfoDart>(
        'GetLastInputInfo',
      );

      _getTickCount64 = kernel32
          .lookupFunction<_GetTickCount64Native, _GetTickCount64Dart>(
        'GetTickCount64',
      );
      _openProcess =
          kernel32.lookupFunction<_OpenProcessNative, _OpenProcessDart>(
        'OpenProcess',
      );
      _queryFullProcessImageNameW = kernel32.lookupFunction<
          _QueryFullProcessImageNameWNative, _QueryFullProcessImageNameWDart>(
        'QueryFullProcessImageNameW',
      );
      _closeHandle =
          kernel32.lookupFunction<_CloseHandleNative, _CloseHandleDart>(
        'CloseHandle',
      );
      _getCurrentProcess = kernel32
          .lookupFunction<_GetCurrentProcessNative, _GetCurrentProcessDart>(
        'GetCurrentProcess',
      );
      _setProcessWorkingSetSize = kernel32.lookupFunction<
          _SetProcessWorkingSetSizeNative, _SetProcessWorkingSetSizeDart>(
        'SetProcessWorkingSetSize',
      );

      _available = true;
    } catch (e) {
      debugPrint('WindowsActivityTracker initialization failed: $e');
      _available = false;
    }
  }

  static void start() {
    if (!isSupported) return;
    if (!_initialized) initialize();
    if (!_available) return;

    _trackerTimer?.cancel();
    _trackerTimer = Timer.periodic(
      const Duration(seconds: _sampleIntervalSeconds),
      (_) => _sample(),
    );

    // Flush to disk every 15 minutes to keep disk I/O near zero
    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(
      const Duration(minutes: 15),
      (_) => LaptopActivityStore.flushSync(),
    );
  }

  static void stop() {
    _trackerTimer?.cancel();
    _trackerTimer = null;
    _flushTimer?.cancel();
    _flushTimer = null;
    LaptopActivityStore.flushSync();
  }

  /// Trims process working set (unreferenced textures and heap) down to bare minimum.
  /// Drops Flutter Windows memory from ~150MB down to <25MB.
  static void trimMemory() {
    if (!_available || _getCurrentProcess == null || _setProcessWorkingSetSize == null) {
      return;
    }
    try {
      final currentProc = _getCurrentProcess!();
      // Passing -1, -1 tells Windows to trim physical working set
      _setProcessWorkingSetSize!(currentProc, -1, -1);
    } catch (_) {}
  }

  static void _sample() {
    if (!LaptopActivityStore.isEnabled()) return;

    final idleMs = _getIdleTimeMilliseconds();
    final idleThresholdMs = LaptopActivityStore.idleThresholdMinutes() * 60 * 1000;

    if (idleMs >= idleThresholdMs) {
      // User is away / idle
      LaptopActivityStore.recordIdle(_sampleIntervalSeconds);
      return;
    }

    final activeExe = _getForegroundProcessName();
    if (activeExe != null && activeExe.isNotEmpty) {
      LaptopActivityStore.recordActiveUsage(activeExe, _sampleIntervalSeconds);
    }
  }

  static int _getIdleTimeMilliseconds() {
    if (_getLastInputInfo == null || _getTickCount64 == null) return 0;

    final pLii = calloc<LASTINPUTINFO>();
    try {
      pLii.ref.cbSize = sizeOf<LASTINPUTINFO>();
      final ok = _getLastInputInfo!(pLii);
      if (ok == 0) return 0;

      final nowTick = _getTickCount64!();
      final lastInputTick = pLii.ref.dwTime;
      // dwTime wraps around every 49.7 days; comparing lower 32 bits of tick count
      final elapsed = (nowTick & 0xFFFFFFFF) - lastInputTick;
      return elapsed > 0 ? elapsed : 0;
    } finally {
      calloc.free(pLii);
    }
  }

  static String? _getForegroundProcessName() {
    if (_getForegroundWindow == null ||
        _getWindowThreadProcessId == null ||
        _openProcess == null ||
        _queryFullProcessImageNameW == null ||
        _closeHandle == null) {
      return null;
    }

    final hwnd = _getForegroundWindow!();
    if (hwnd == 0) return null;

    final pPid = calloc<Uint32>();
    final pSize = calloc<Uint32>();
    final pPath = calloc<Uint16>(1024);

    try {
      _getWindowThreadProcessId!(hwnd, pPid);
      final pid = pPid.value;
      if (pid == 0) return null;

      final hProc = _openProcess!(_processQueryLimitedInfo, 0, pid);
      if (hProc == 0) return null;

      try {
        pSize.value = 1024;
        final ok = _queryFullProcessImageNameW!(hProc, 0, pPath.cast<Utf16>(), pSize);
        if (ok != 0) {
          final fullPath = pPath.cast<Utf16>().toDartString();
          final slashIdx = fullPath.lastIndexOf(r'\');
          return slashIdx >= 0 ? fullPath.substring(slashIdx + 1) : fullPath;
        }
      } finally {
        _closeHandle!(hProc);
      }
    } catch (_) {
      return null;
    } finally {
      calloc.free(pPid);
      calloc.free(pSize);
      calloc.free(pPath);
    }
    return null;
  }
}
