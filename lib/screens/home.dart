import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phoenix/core/app_state.dart';
import 'package:phoenix/services/notification_service.dart';
import 'package:phoenix/widgets/home/home_header.dart';
import 'package:phoenix/widgets/home/month_header.dart';
import 'package:phoenix/widgets/home/weekday_row.dart';
import 'package:phoenix/widgets/home/calendar_day_cell.dart';
import 'package:phoenix/widgets/home/journal_card.dart';
import 'package:phoenix/widgets/home/today_entry_card.dart';
import 'package:phoenix/screens/today_entry_detail_page.dart';
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
    bool _isLoadingMore = false;
    bool _hasMoreJournals = true;
    int _journalPage = 0;
    final int _journalPageSize = 10;
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
            _name = userModel.name.isNotEmpty ? userModel.name : 'No Name';
            _tagline = userModel.username.isNotEmpty ? '@${userModel.username}' : '@username';
            _bio = (userModel.desc != null && userModel.desc!.isNotEmpty)
              ? userModel.desc!
              : '-';
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
      // For lazy loading, only show first page
      _journalPage = 1;
      _hasMoreJournals = journals.length > _journalPageSize;
      _journals = journals.take(_journalPageSize).toList();
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
  String _bio = '-';
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
        onTap: cd.isOutside ? null : () async {
          setState(() => _selectedDay = cd.date);
          // Find journals for the selected date
          final journalsForDay = _journals.where((j) => _isSameDay(j.date, cd.date)).toList();
          if (journalsForDay.isNotEmpty) {
            // Prefer journal with photo
            final journalWithPhoto = journalsForDay.firstWhere(
              (j) => j.photoUrl != null && j.photoUrl!.isNotEmpty,
              orElse: () => journalsForDay.last,
            );
            await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (ctx) => TodayEntryDetailPage(
                headline: journalWithPhoto.headline,
                body: journalWithPhoto.body,
                mood: journalWithPhoto.mood,
                date: journalWithPhoto.date,
                photoUrl: journalWithPhoto.photoUrl ?? '',
              ),
            );
          }
        },
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
        child: RefreshIndicator(
          onRefresh: _fetchProfileAndJournals,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12),
                _buildHeader(context),
                const SizedBox(height: 10),
                _buildMonthHeader(),
                const SizedBox(height: 6),
                _buildWeekdayRow(),
                const SizedBox(height: 4),
                _buildDayGrid(days, today),
                const SizedBox(height: 14),
                _buildTodayEntrySection(today),
                const SizedBox(height: 12),
                _buildJournalListTitle(),
                _buildJournalList(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeHeader(
          avatarUrl: _avatarUrl ?? '',
          name: _name,
          tagline: _tagline,
          onSettings: () => context.go('/edit_profile'),
          onLogout: () => _logout(context),
        ),
        const SizedBox(height: 6),
        Text(
          _bio.isNotEmpty ? _bio : '-',
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
      ],
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
    // Cancel today's notification automatically if photo is logged
    if (journalWithPhoto.isNotEmpty) {
      Future.microtask(() async {
        await NotificationService().cancel(1);
        await NotificationService().cancel(2);
      });
    }
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
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (ctx) => TodayEntryDetailPage(
                  headline: journal.headline,
                  body: journal.body,
                  mood: journal.mood,
                  date: journal.date,
                  photoUrl: journal.photoUrl ?? '',
                ),
              );
            },
            child: Stack(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade200,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      journal.photoUrl ?? '',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz, color: Colors.black, size: 20),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete Journal'),
                      ),
                    ],
                    onSelected: (value) async {
                      if (value == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Journal'),
                            content: const Text('Are you sure you want to delete this journal?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                              TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await SupabaseJournalService().deleteJournal(journal.journalId);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Journal deleted.')));
                            _fetchProfileAndJournals();
                          }
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
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
    // Lazy loading: show initial batch, load more on scroll
    Future<void> _loadMoreJournals() async {
      if (_isLoadingMore || !_hasMoreJournals) return;
      setState(() => _isLoadingMore = true);
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final journalMaps = await SupabaseJournalService().fetchJournals(user.uid);
        final allJournals = journalMaps.map<JournalModel>((data) => JournalModel.fromSupabase(data)).toList();
        final nextPage = allJournals.skip(_journalPage * _journalPageSize).take(_journalPageSize).toList();
        setState(() {
          _journals.addAll(nextPage);
          _journalPage++;
          _hasMoreJournals = allJournals.length > _journalPage * _journalPageSize;
          _isLoadingMore = false;
        });
      } else {
        setState(() => _isLoadingMore = false);
      }
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 100 && !_isLoadingMore && _hasMoreJournals) {
          _loadMoreJournals();
        }
        return false;
      },
      child: Column(
        children: _journals
          .where((j) => j.photoUrl == null || j.photoUrl!.isEmpty || DateTime(j.date.year, j.date.month, j.date.day) != DateTime.now())
          .map((j) => Stack(
            children: [
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => TodayEntryDetailPage(
                      headline: j.headline,
                      body: j.body,
                      mood: j.mood,
                      date: j.date,
                      photoUrl: j.photoUrl ?? '',
                    ),
                  );
                },
                child: JournalCard(
                  date: j.date,
                  headline: j.headline,
                  body: j.body,
                  mood: j.mood,
                  tag: 'Adventures', // Example tag, replace with actual if available
                  onDetail: null,
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz, color: Colors.black, size: 20),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete Journal'),
                    ),
                  ],
                  onSelected: (value) async {
                    if (value == 'delete') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Journal'),
                          content: const Text('Are you sure you want to delete this journal?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                            TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await SupabaseJournalService().deleteJournal(j.journalId);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Journal deleted.')));
                          _fetchProfileAndJournals();
                        }
                      }
                    }
                  },
                ),
              ),
            ],
          ))
          .toList(),
      ),
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
