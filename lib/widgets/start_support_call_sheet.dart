import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/call/call_controller.dart';
import '../utils/constants.dart';
import 'modern_select_sheet.dart';

/// Bottom sheet to start an in-app voice call to a dispatcher (JWT `sub`).
/// Shared by IT support home and ticket detail.
class StartSupportCallSheet extends StatefulWidget {
  const StartSupportCallSheet({super.key});

  @override
  State<StartSupportCallSheet> createState() => _StartSupportCallSheetState();
}

class _StartSupportCallSheetState extends State<StartSupportCallSheet> {
  final TextEditingController _dispatcherIdController = TextEditingController();
  final AuthService _authService = AuthService.instance;
  List<AuthRoleUser> _dispatchers = const [];
  String? _selectedDispatcherId;
  bool _isLoadingDispatchers = false;
  String? _dispatcherLoadError;
  bool _isStarting = false;

  @override
  void initState() {
    super.initState();
    _loadDispatchers();
  }

  @override
  void dispose() {
    _dispatcherIdController.dispose();
    super.dispose();
  }

  AuthRoleUser? get _selectedDispatcher {
    for (final dispatcher in _dispatchers) {
      if (dispatcher.id == _selectedDispatcherId) return dispatcher;
    }
    return null;
  }

  Future<void> _loadDispatchers() async {
    setState(() {
      _isLoadingDispatchers = true;
      _dispatcherLoadError = null;
    });
    try {
      final users = await _authService.fetchUsersByRole('Dispatcher');
      if (!mounted) return;
      setState(() {
        _dispatchers = users;
        _selectedDispatcherId = users.isNotEmpty ? users.first.id : null;
        _dispatcherIdController.text = _selectedDispatcherId ?? '';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _dispatcherLoadError = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingDispatchers = false);
      }
    }
  }

  String _selectedDispatcherLabel() {
    final id = _selectedDispatcherId;
    if (id == null) return '';
    for (final u in _dispatchers) {
      if (u.id == id) return u.displayName;
    }
    return id;
  }

  Future<void> _startCall() async {
    final id = (_selectedDispatcherId ?? _dispatcherIdController.text).trim();
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a dispatcher.')),
      );
      return;
    }

    setState(() => _isStarting = true);
    try {
      await CallController.instance.requestCall(
        id,
        dispatcherDisplayName: _selectedDispatcher?.displayName,
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _isStarting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Start in-app support call',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.gray900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Connect to a support dispatcher over a secure voice channel.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.gray600,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoadingDispatchers)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Loading dispatchers...',
                      style: TextStyle(fontSize: 13, color: AppColors.gray600),
                    ),
                  ],
                ),
              )
            else if (_dispatchers.isNotEmpty)
              GestureDetector(
                onTap: _isStarting
                    ? null
                    : () async {
                        final result = await showModernSelectSheet<String>(
                          context: context,
                          title: 'Select Dispatcher',
                          selectedValue: _selectedDispatcherId,
                          options: _dispatchers
                              .map((u) => SelectOption(
                                    value: u.id,
                                    label: u.displayName,
                                    icon: Icons.support_agent_outlined,
                                  ))
                              .toList(growable: false),
                        );
                        if (result != null) {
                          setState(() {
                            _selectedDispatcherId = result;
                            _dispatcherIdController.text = result;
                          });
                        }
                      },
                child: AbsorbPointer(
                  child: TextFormField(
                    key: ValueKey(_selectedDispatcherId),
                    initialValue: _selectedDispatcherLabel(),
                    decoration: InputDecoration(
                      labelText: 'Dispatcher',
                      hintText: 'Select dispatcher',
                      prefixIcon:
                          const Icon(Icons.support_agent_outlined, size: 20),
                      suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: AppColors.gray400, size: 22),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.gray200),
                      ),
                      filled: true,
                      fillColor: AppColors.gray50,
                    ),
                  ),
                ),
              )
            else
              TextField(
                controller: _dispatcherIdController,
                autofocus: true,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _startCall(),
                decoration: InputDecoration(
                  labelText: 'Dispatcher user id',
                  hintText: 'Paste dispatcher id',
                  prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            if (_dispatcherLoadError != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.info_outline,
                      size: 16, color: AppColors.gray500),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'Could not auto-load dispatchers. You can still paste an id.',
                      style: TextStyle(fontSize: 12, color: AppColors.gray500),
                    ),
                  ),
                  TextButton(
                    onPressed: _isLoadingDispatchers ? null : _loadDispatchers,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            const Text(
              'Your microphone will be used for this call.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.gray500,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isStarting ? null : _startCall,
                icon: _isStarting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.call, size: 18),
                label: Text(_isStarting ? 'Connecting...' : 'Call now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
