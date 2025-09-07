import 'package:fairnestui/pages/House%20Rules/EditHouseRulePage.dart';
import 'package:fairnestui/services/house_rules_service.dart';
import 'package:fairnestui/model/house_rules_model.dart';
import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/theme/app_fonts.dart';
import 'package:fairnestui/components/MainButton.dart';

Future<bool?> showEditHouseRulesDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (_) => const EditHouseRulesDialog(),
  );
}

class EditHouseRulesDialog extends StatelessWidget {
  const EditHouseRulesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final future = HouseRulesService().getForCurrentRoom();

    return Dialog(
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: Colors.transparent,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Material(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 24),
                      Expanded(
                        child: Text(
                          'House Rules',
                          textAlign: TextAlign.center,
                          style: AppFonts.heading2.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPurple,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => Navigator.of(context).pop(false),
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(Icons.close,
                              size: 20, color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "These rules are editable later by the group.\nYou're only reviewing the current setup.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Krub',
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      height: 1.4,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: FutureBuilder<HouseRules?>(
                      future: future,
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                                child:
                                    CircularProgressIndicator(strokeWidth: 2)),
                          );
                        }
                        if (snap.hasError) {
                          return const _ErrorPane(
                              message: 'Failed to load house rules.');
                        }
                        final rules = snap.data;
                        if (rules == null) {
                          return const _ErrorPane(
                              message: 'No house rules found for this room.');
                        }

                        // PRESENTATION (what the user sees in the dialog)
                        final quietTxt = _presentQuiet(rules.quietHoursStart);
                        final guestTxt = _presentTextOrNA(rules.guestStayOver);
                        final cleaningTxt =
                            _presentTextOrNA(rules.handleCleaning);
                        final sharedExtra = (rules.sharedSpace
                                    ?.trim()
                                    .isNotEmpty ??
                                false)
                            ? 'Shared responsibilities: ${rules.sharedSpace}'
                            : null;
                        final expensesTxt = (rules.splitCosts == null)
                            ? 'Not set'
                            : (rules.splitCosts! ? 'Equal split' : 'Custom');

                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _RuleSection(
                                  title: 'Quiet Hours', value: quietTxt),
                              _RuleSection(
                                  title: 'Guest Policy', value: guestTxt),
                              _RuleSection(
                                  title: 'Cleaning & Chores',
                                  value: cleaningTxt,
                                  extra: sharedExtra),
                              _RuleSection(
                                  title: 'Shared Expenses', value: expensesTxt),
                              const SizedBox(height: 16),

                              // ➜ open Edit page with mapped initialData (NO API there)
                              MainButton(
                                text: 'Edit House Rule',
                                onPressed: () {
                                  final initial =
                                      _mapHouseRulesToEditData(rules);
                                  Navigator.of(context).pop();
                                  Future.microtask(() {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            EditHousePage(initialData: initial),
                                      ),
                                    );
                                  });
                                },
                                backgroundColor: const Color(0xFFE8B86D),
                                textColor: Colors.black,
                                width: double.infinity,
                                height: 56,
                                borderRadius: 12,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _presentQuiet(String? start) {
  final s = start?.trim();
  if (s == null || s.isEmpty) return 'Not set';
  if (s == '22:00') return '10 PM – 7 AM';
  if (s == '23:00') return '11 PM – 6 AM';
  if (s.toLowerCase() == 'none') return 'No quiet hours';
  return 'Custom ($s)';
}

String _presentTextOrNA(String? t) =>
    (t?.trim().isNotEmpty ?? false) ? t!.trim() : 'Not set';

class _RuleSection extends StatelessWidget {
  const _RuleSection({required this.title, required this.value, this.extra});
  final String title;
  final String value;
  final String? extra;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppFonts.heading3.copyWith(
                  color: AppColors.textDark, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _RulePill(text: value),
          if (extra != null) ...[
            const SizedBox(height: 8),
            _RulePill(text: extra!),
          ],
        ],
      ),
    );
  }
}

class _RulePill extends StatelessWidget {
  const _RulePill({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side:
              BorderSide(color: AppColors.primary.withOpacity(0.7), width: 1.2),
        ),
        shadows: [
          BoxShadow(
              blurRadius: 6,
              offset: const Offset(0, 2),
              color: Colors.black.withOpacity(0.06)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Text(
          text,
          style: AppFonts.heading3.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.textDark.withOpacity(0.85)),
        ),
      ),
    );
  }
}

class _ErrorPane extends StatelessWidget {
  const _ErrorPane({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 20, color: Colors.redAccent),
          const SizedBox(height: 8),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

/// -------------------------
/// STRICT mapper: API → your enums (only the options you support)
/// -------------------------
EditHouseRuleData _mapHouseRulesToEditData(HouseRules r) {
  // Quiet Hours (API only gives start like "22:00")
  final start = (r.quietHoursStart ?? '').trim();
  QuietHoursOption? qOpt;
  String? qCustom;
  if (start.isEmpty || start.toLowerCase() == 'none') {
    qOpt = QuietHoursOption.none;
  } else if (start == '22:00') {
    qOpt = QuietHoursOption.tenToSeven;
  } else if (start == '23:00') {
    qOpt = QuietHoursOption.elevenToSix;
  } else {
    qOpt = QuietHoursOption.custom;
    qCustom =
        start; // keep raw time; UI will show it in the "Custom" text field
  }

  // Guest Policy
  final g = (r.guestStayOver ?? '').toLowerCase();
  GuestPolicyOption? gOpt;
  if (g.contains('no overnight')) {
    gOpt = GuestPolicyOption.noOvernight;
  } else if ((g.contains('1') && g.contains('week')) ||
      g.contains('one night')) {
    gOpt = GuestPolicyOption.max1NightWeek;
  } else if ((g.contains('3') && g.contains('month')) || g.contains('three')) {
    gOpt = GuestPolicyOption.max3NightsMonth;
  } else if (g.isEmpty) {
    gOpt = null;
  } else {
    // e.g. "Allowed with prior notice" → best match to your last option
    gOpt = GuestPolicyOption.noRestriction;
  }

  // Cleaning Method
  final c = (r.handleCleaning ?? '').toLowerCase();
  CleaningMethodOption? cOpt;
  if (c.contains('weekly')) {
    cOpt = CleaningMethodOption.weekly;
  } else if (c.contains('bi') && c.contains('week')) {
    cOpt = CleaningMethodOption.biweekly;
  } else if (c.contains('assign')) {
    cOpt = CleaningMethodOption.assigned;
  } else if (c.isEmpty) {
    cOpt = null;
  } else {
    cOpt = CleaningMethodOption.flexible;
  }

  // Responsibilities
  final resp = (r.sharedSpace ?? '').toLowerCase();
  final respSet = <ResponsibilityOption>{};
  if (resp.contains('kitchen')) respSet.add(ResponsibilityOption.kitchen);
  if (resp.contains('living')) respSet.add(ResponsibilityOption.livingRoom);
  if (resp.contains('bathroom')) respSet.add(ResponsibilityOption.bathroom);
  if (resp.contains('trash') || resp.contains('garbage'))
    respSet.add(ResponsibilityOption.trash);

  // Split Costs
  final sOpt =
      (r.splitCosts == true) ? SplitCostsOption.equal : SplitCostsOption.custom;

  return EditHouseRuleData(
    quietHours: qOpt,
    quietHoursCustom: qCustom,
    guestPolicy: gOpt,
    cleaningMethod: cOpt,
    responsibilities: respSet.toList(),
    splitCosts: sOpt,
  );
}
