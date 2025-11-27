import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phoenix/core/app_state.dart';
import 'package:phoenix/widgets/home/home_header.dart';
import 'package:phoenix/widgets/home/month_header.dart';
import 'package:phoenix/widgets/home/weekday_row.dart';
import 'package:phoenix/widgets/home/calendar_day_cell.dart';
import 'package:phoenix/widgets/home/journal_card.dart';
import 'package:phoenix/widgets/home/upload_button.dart';
import 'package:phoenix/widgets/home/today_entry_card.dart';
import 'package:phoenix/services/supabase_journal_service.dart';
import 'package:phoenix/services/supabase_user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:phoenix/models/journal_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  RealtimeChannel? _journalSubscription;
    Future<void> _fetchProfileAndJournals() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Fetch profile
      final userModel = await SupabaseUserService().getUser(user.uid);
      if (userModel != null) {
        if (mounted) {
          setState(() {
            _avatarUrl = userModel.profilePicUrl.isNotEmpty ? userModel.profilePicUrl : null;
            _name = userModel.name;
            _tagline = userModel.username.isNotEmpty ? '@${userModel.username}' : '';
            loadingProfile = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            loadingProfile = false;
          });
        }
      }
      // Fetch journals
      final journalMaps = await SupabaseJournalService().fetchJournals(user.uid);
      final journals = journalMaps.map<JournalModel>((data) => JournalModel.fromSupabase(data)).toList();
      // Update loggedDays and photoDays
      final logged = <DateTime>{};
      final photoDays = <DateTime>{};
      for (final j in journals) {
        final d = DateTime(j.date.year, j.date.month, j.date.day);
        logged.add(d);
        if (j.photoUrl != null && j.photoUrl!.isNotEmpty) {
          photoDays.add(d);
        }
      }
      if (mounted) {
        setState(() {
          _journals = journals;
          _loggedDays = logged;
          _photoDays = photoDays;
          loadingJournals = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          loadingProfile = false;
          loadingJournals = false;
        });
      }
    }
    }
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime? _selectedDay;
  Set<DateTime> _loggedDays = {};
  Set<DateTime> _photoDays = {};
  List<JournalModel> _journals = [];
  bool loadingJournals = true;
  String? _avatarUrl;
  String _name = '';
  String _tagline = '';
  bool loadingProfile = true;

  String _monthName(int m) {
    const names = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return names[m - 1];
  }

  Widget _buildDayGrid(List<_CalendarDay> days, DateTime today) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: days.map((cd) => CalendarDayCell(
        date: cd.date,
        isOutside: cd.isOutside,
        isToday: _isSameDay(cd.date, today),
        isSelected: _selectedDay != null && _isSameDay(cd.date, _selectedDay!),
        isLogged: _loggedDays.contains(cd.date),
        hasPhoto: _photoDays.contains(cd.date),
        onTap: cd.isOutside ? null : () => setState(() => _selectedDay = cd.date),
      )).toList(),
    );
  }

  Widget _buildWeekdayRow() {
    return const WeekdayRow();
  }

  @override
  void initState() {
    super.initState();
    _fetchProfileAndJournals();
    // Subscribe to journals table changes
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final channel = Supabase.instance.client
        .channel('public:journals')
        .on(
          RealtimeListenTypes.postgresChanges,
          ChannelFilter(
            event: '*',
            schema: 'public',
            table: 'journals',
            filter: 'uid=eq.${user.uid}',
          ),
          (payload, [ref]) async {
            if (mounted) {
              await _fetchProfileAndJournals();
            }
          },
        );
      channel.subscribe();
      _journalSubscription = channel;
    }
  }

  @override
  void dispose() {
    if (_journalSubscription != null) {
      Supabase.instance.client.removeChannel(_journalSubscription!);
    }
    super.dispose();
  }

  // Removed unused _fetchJournals method

  Future<void> _logout(BuildContext context) async {
    final state = await AppState.create();
    await state.signOut();
    if (context.mounted) context.go('/signin');
  }

  void _prevMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = _generateCalendarDays(_focusedMonth);
    final todayDate = DateTime(today.year, today.month, today.day);
    final hasPhotoToday = _photoDays.contains(todayDate);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 10),
              _buildMonthHeader(),
              const SizedBox(height: 6),
              _buildWeekdayRow(),
              const SizedBox(height: 4),
              _buildDayGrid(days, today),
              const SizedBox(height: 14),
              _buildTodayEntrySection(today),
              if (!hasPhotoToday) ...[
                const SizedBox(height: 12),
                _buildUploadButton(context),
              ],
              const SizedBox(height: 18),
              _buildJournalListTitle(),
              _buildJournalList(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return HomeHeader(
      avatarUrl: _avatarUrl ?? '',
      name: _name,
      tagline: _tagline,
      onSettings: () => context.go('/settings'),
      onLogout: () => _logout(context),
    );
  }

  Widget _buildMonthHeader() {
    final monthLabel = "${_monthName(_focusedMonth.month)} ${_focusedMonth.year}";
    final totalEntries = _loggedDays.where((d) => d.month == _focusedMonth.month && d.year == _focusedMonth.year).length;
    return MonthHeader(
      monthLabel: monthLabel,
      totalEntries: totalEntries,
      onPrevMonth: _prevMonth,
      onNextMonth: _nextMonth,
    );
  }


  Widget _buildTodayEntrySection(DateTime today) {
    final todayDate = DateTime(today.year, today.month, today.day);
    final journalWithPhoto = _journals.where(
      (j) => DateTime(j.date.year, j.date.month, j.date.day) == todayDate && j.photoUrl != null && j.photoUrl!.isNotEmpty,
    ).toList();
    if (journalWithPhoto.isNotEmpty) {
      final journal = journalWithPhoto.first;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Entry",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          const Text(
            "Goodjob, your entry today will make yourself proud tomorrow.",
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              journal.photoUrl!,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  journal.headline.isNotEmpty ? journal.headline : journal.body,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                "${journal.date.day.toString().padLeft(2, '0')} ${_monthName(journal.date.month)} ${journal.date.year}",
                style: const TextStyle(fontSize: 11, color: Colors.black45),
              ),
            ],
          ),
        ],
      );
    }
    final hasLoggedToday = _loggedDays.contains(todayDate);
    return TodayEntryCard(
      entryText: hasLoggedToday
        ? 'You already logged today, feel free to log whenever you\'re ready again.'
        : "You haven't log your entry today, feel free to log whenever you're ready",
    );
  }

  Widget _buildUploadButton(BuildContext context) {
    return const UploadButton();
  }

  Widget _buildJournalListTitle() {
    return const Text('Your Journals', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600));
  }

  Widget _buildJournalList() {
    if (loadingJournals) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_journals.isEmpty) {
      return const Center(child: Text('No journal entries yet.', style: TextStyle(color: Colors.black38)));
    }
    return Column(
      children: _journals.map((j) => JournalCard(
        date: j.date,
        text: j.headline.isNotEmpty ? j.headline : j.body,
      )).toList(),
    );
  }




  List<_CalendarDay> _generateCalendarDays(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // Monday=1 -> we want number of leading slots before first day (Mon aligned)
    final leading = (first.weekday + 6) % 7; // convert Monday=1 to 0 offset, Sunday=7 to 6
    final list = <_CalendarDay>[];
    // Previous month tail
    for (int i = leading; i > 0; i--) {
      final date = first.subtract(Duration(days: i));
      list.add(_CalendarDay(date: date, isOutside: true));
    }
    // Current month
    for (int d = 1; d <= daysInMonth; d++) {
      list.add(_CalendarDay(date: DateTime(month.year, month.month, d), isOutside: false));
    }
    // Trailing days to complete grid (up to full weeks)
    int remainder = list.length % 7;
    if (remainder != 0) {
      int toAdd = 7 - remainder;
      final last = list.last.date;
      for (int i = 1; i <= toAdd; i++) {
        list.add(_CalendarDay(date: last.add(Duration(days: i)), isOutside: true));
      }
    }
    return list;
  }
}

class _CalendarDay {
  final DateTime date;
  final bool isOutside;
  _CalendarDay({required this.date, required this.isOutside});
}
