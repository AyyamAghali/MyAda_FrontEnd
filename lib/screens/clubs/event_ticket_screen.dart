import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../models/club_public_event.dart';
import '../../models/event_tickets_models.dart';
import '../../services/club_api_service.dart';
import '../../services/remote_event_tickets_repository.dart';
import '../../services/event_tickets_repository.dart';
import '../../utils/constants.dart';

class EventTicketScreen extends StatefulWidget {
  final int eventId;

  const EventTicketScreen({super.key, required this.eventId});

  @override
  State<EventTicketScreen> createState() => _EventTicketScreenState();
}

class _EventTicketScreenState extends State<EventTicketScreen> {
  bool _loading = true;
  RegistrationTicket? _ticket;
  ClubPublicEvent? _eventDetail;
  String? _error;
  final EventTicketsRepository _repo = RemoteEventTicketsRepository();
  final ClubApiService _api = ClubApiService();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        _repo.getTicket(widget.eventId.toString()),
        _api.fetchEventById(widget.eventId),
      ]);
      if (!mounted) return;
      setState(() {
        _ticket = results[0] as RegistrationTicket?;
        _eventDetail = results[1] as ClubPublicEvent?;
        _error = null;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _ticket = null;
        _error = 'Ticket not found.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = _eventDetail;
    final token = _ticket?.jwt ?? '';
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray900,
        elevation: 0,
        title: const Text('Ticket'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_ticket == null || event == null)
              ? Center(child: Text(_error ?? 'Ticket not found.'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _headerCard(event),
                      const SizedBox(height: 14),
                      _qrCard(token),
                      const SizedBox(height: 14),
                      if (token.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 14),
                          child: Text(
                            'Warning: ticket token is missing. QR could not be generated.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFB45309),
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      _metaCard(_ticket!),
                    ],
                  ),
                ),
    );
  }

  Widget _headerCard(event) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.primary.withValues(alpha: 0.08),
            ),
            child: const Icon(Icons.confirmation_number_outlined,
                color: AppColors.primary, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${event.date} • ${event.time}${event.endTime != null ? ' - ${event.endTime}' : ''}',
                  style: const TextStyle(fontSize: 12, color: AppColors.gray600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  event.location,
                  style: const TextStyle(fontSize: 12, color: AppColors.gray600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _qrCard(String jwt) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Show this QR at the entrance',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.gray200),
            ),
            child: QrImageView(
              // QR encodes the ticket JWT; the raw token is not shown in the UI.
              data: jwt.isNotEmpty ? jwt : ' ',
              version: QrVersions.auto,
              size: 220,
              backgroundColor: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaCard(RegistrationTicket ticket) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.badge_outlined, size: 18, color: AppColors.gray600),
              const SizedBox(width: 8),
              const Text(
                'Ticket details',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray900,
                ),
              ),
              const Spacer(),
              Text(
                ticket.ticketId,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}

