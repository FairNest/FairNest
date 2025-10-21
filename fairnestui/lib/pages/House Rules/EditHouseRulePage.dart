// lib/pages/House Rules/EditHouseRulePage.dart
import 'package:fairnestui/widgets/app_header.dart';
import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/theme/app_fonts.dart';
import 'package:fairnestui/components/MainButton.dart';
import 'package:fairnestui/model/house_rules_model.dart';
import 'package:fairnestui/services/house_rules_service.dart';

/* ===================== Page ===================== */

class EditHousePage extends StatefulWidget {
  const EditHousePage({super.key, this.onSubmit, this.initialData});

  final void Function(EditHouseRuleData data)? onSubmit;

  /// comes from the dialog (already mapped from API)
  final EditHouseRuleData? initialData;

  @override
  State<EditHousePage> createState() => _EditHousePageState();
}

class _EditHousePageState extends State<EditHousePage> {
  QuietHoursOption? _quietHours;
  GuestPolicyOption? _guestPolicy;
  CleaningMethodOption? _cleaningMethod;
  final Set<ResponsibilityOption> _responsibilities = {};
  SplitCostsOption? _splitCosts;

  String? _quietHoursCustom; // for custom

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    if (d != null) {
      _quietHours = d.quietHours;
      _quietHoursCustom = d.quietHoursCustom;
      _guestPolicy = d.guestPolicy;
      _cleaningMethod = d.cleaningMethod;
      _responsibilities
        ..clear()
        ..addAll(d.responsibilities);
      _splitCosts = d.splitCosts;
    }
  }

  Future<void> _submit() async {
    final data = EditHouseRuleData(
      quietHours: _quietHours,
      quietHoursCustom: _quietHoursCustom,
      guestPolicy: _guestPolicy,
      cleaningMethod: _cleaningMethod,
      responsibilities: _responsibilities.toList(),
      splitCosts: _splitCosts,
    );
    widget.onSubmit?.call(data);

    // Map UI → PATCH payload
    final patch = _mapEditDataToPatch(data);

    setState(() => _saving = true);
    try {
      await HouseRulesService().patchForCurrentRoom(patch);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('House rules updated')),
      );
      Navigator.of(context).pop(true); // close page after save
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const AppHeader(
            title: 'Edit House Rules',
            showBack: true,
            rightType: AppHeaderRightType.none,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 16, bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Intro
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Roommate Agreement',
                          style: AppFonts.heading1
                              .copyWith(color: const Color(0xFF645A80)),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Set up your shared living rules by selecting the options that work best for your group. You can always edit these later.',
                          style: TextStyle(
                            fontFamily: 'Krub',
                            fontSize: 12,
                            color: Color(0xFF6C6577),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),
                  const _SectionBar(label: 'Quiet Hours'),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 14),
                        const _FieldLabel('When should quiet hours start?'),
                        _SelectTile(
                          valueText: _quietHours == null
                              ? null
                              : _quietHours == QuietHoursOption.custom
                                  ? (_quietHoursCustom?.isNotEmpty == true
                                      ? _quietHoursCustom
                                      : 'Custom')
                                  : quietHoursLabels[_quietHours]!,
                          onTap: () async {
                            final sel =
                                await _showRadioSelector<QuietHoursOption>(
                              context: context,
                              title: 'Quiet Hours',
                              options: quietHoursLabels,
                              selected: _quietHours,
                              extraFooter: (ctx, setStateSheet) {
                                if (_quietHours == QuietHoursOption.custom) {
                                  return Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 6, 16, 12),
                                    child: TextField(
                                      controller: TextEditingController(
                                          text: _quietHoursCustom ?? ''),
                                      decoration: const InputDecoration(
                                        hintText: 'e.g. 22:00',
                                        filled: true,
                                        fillColor: Color(0xFFF5F2EE),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 12),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      onChanged: (t) => _quietHoursCustom = t,
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                              onChanged: (v) {
                                setState(() {
                                  _quietHours = v;
                                  if (v != QuietHoursOption.custom) {
                                    _quietHoursCustom = null;
                                  }
                                });
                              },
                            );
                            if (sel != null) {
                              setState(() {
                                _quietHours = sel;
                                if (sel != QuietHoursOption.custom) {
                                  _quietHoursCustom = null;
                                }
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),
                  const _SectionBar(label: 'Guest Policy'),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 14),
                        const _FieldLabel('How often can guests stay over?'),
                        _SelectTile(
                          valueText: _guestPolicy == null
                              ? null
                              : guestPolicyLabels[_guestPolicy]!,
                          onTap: () async {
                            final sel =
                                await _showRadioSelector<GuestPolicyOption>(
                              context: context,
                              title: 'Guest Policy',
                              options: guestPolicyLabels,
                              selected: _guestPolicy,
                              onChanged: (v) =>
                                  setState(() => _guestPolicy = v),
                            );
                            if (sel != null) setState(() => _guestPolicy = sel);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),
                  const _SectionBar(label: 'Cleaning & Chores'),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 14),
                        const _FieldLabel('How do we handle cleaning?'),
                        _SelectTile(
                          valueText: _cleaningMethod == null
                              ? null
                              : cleaningMethodLabels[_cleaningMethod]!,
                          onTap: () async {
                            final sel =
                                await _showRadioSelector<CleaningMethodOption>(
                              context: context,
                              title: 'Cleaning Method',
                              options: cleaningMethodLabels,
                              selected: _cleaningMethod,
                              onChanged: (v) =>
                                  setState(() => _cleaningMethod = v),
                            );
                            if (sel != null) {
                              setState(() => _cleaningMethod = sel);
                            }
                          },
                        ),
                        const SizedBox(height: 14),
                        const _FieldLabel(
                            'Shared space responsibilities (select all that apply)'),
                        _SelectTile(
                          valueText: _responsibilities.isEmpty
                              ? null
                              : _responsibilities
                                  .map((e) => responsibilitiesLabels[e]!)
                                  .join(', '),
                          onTap: () async {
                            final sel =
                                await _showMultiSelector<ResponsibilityOption>(
                              context: context,
                              title: 'Responsibilities',
                              options: responsibilitiesLabels,
                              initiallySelected: _responsibilities,
                            );
                            if (sel != null) {
                              setState(() {
                                _responsibilities
                                  ..clear()
                                  ..addAll(sel);
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),
                  const _SectionBar(label: 'Shared Expenses'),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 14),
                        const _FieldLabel('How should we split costs?'),
                        _SelectTile(
                          valueText: _splitCosts == null
                              ? null
                              : splitCostsLabels[_splitCosts]!,
                          onTap: () async {
                            final sel =
                                await _showRadioSelector<SplitCostsOption>(
                              context: context,
                              title: 'Split Costs',
                              options: splitCostsLabels,
                              selected: _splitCosts,
                              onChanged: (v) => setState(() => _splitCosts = v),
                            );
                            if (sel != null) setState(() => _splitCosts = sel);
                          },
                        ),
                        const SizedBox(height: 24),
                        MainButton(
                          text: _saving ? 'Saving...' : 'Save',
                          backgroundColor: const Color(0xFFD8A85B),
                          textColor: Colors.black,
                          width: double.infinity,
                          height: 52,
                          borderRadius: 12,
                          onPressed: _saving ? null : _submit,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ===================== Data Model (UI) ===================== */

class EditHouseRuleData {
  final QuietHoursOption? quietHours;
  final String? quietHoursCustom;

  final GuestPolicyOption? guestPolicy;
  final CleaningMethodOption? cleaningMethod;
  final List<ResponsibilityOption> responsibilities;
  final SplitCostsOption? splitCosts;

  const EditHouseRuleData({
    required this.quietHours,
    required this.quietHoursCustom,
    required this.guestPolicy,
    required this.cleaningMethod,
    required this.responsibilities,
    required this.splitCosts,
  });
}

/* ===================== Enums & Labels ===================== */

enum QuietHoursOption { tenToSeven, elevenToSix, none, custom }

enum GuestPolicyOption {
  noOvernight,
  max1NightWeek,
  max3NightsMonth,
  noRestriction
}

enum CleaningMethodOption { weekly, biweekly, assigned, flexible }

enum ResponsibilityOption { kitchen, livingRoom, bathroom, trash }

enum SplitCostsOption { equal, custom }

const quietHoursLabels = <QuietHoursOption, String>{
  QuietHoursOption.tenToSeven: '10 PM – 7 AM',
  QuietHoursOption.elevenToSix: '11 PM – 6 AM',
  QuietHoursOption.none: 'No quiet hours',
  QuietHoursOption.custom: 'Custom',
};

const guestPolicyLabels = <GuestPolicyOption, String>{
  GuestPolicyOption.noOvernight: 'No overnight guests',
  GuestPolicyOption.max1NightWeek: 'Max 1 night/week',
  GuestPolicyOption.max3NightsMonth: 'Max 3 nights/month',
  GuestPolicyOption.noRestriction: 'No restriction (notify group)',
};

const cleaningMethodLabels = <CleaningMethodOption, String>{
  CleaningMethodOption.weekly: 'Weekly rotation',
  CleaningMethodOption.biweekly: 'Bi-weekly rotation',
  CleaningMethodOption.assigned: 'Assigned to specific people',
  CleaningMethodOption.flexible: 'Flexible',
};

const responsibilitiesLabels = <ResponsibilityOption, String>{
  ResponsibilityOption.kitchen: 'Kitchen',
  ResponsibilityOption.livingRoom: 'Living Room',
  ResponsibilityOption.bathroom: 'Bathroom',
  ResponsibilityOption.trash: 'Trash',
};

const splitCostsLabels = <SplitCostsOption, String>{
  SplitCostsOption.equal: 'Equal split',
  SplitCostsOption.custom: 'Custom',
};

/* ===================== UI Bits & Selectors ===================== */

class _SectionBar extends StatelessWidget {
  const _SectionBar({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 53,
      child: ColoredBox(
        color: AppColors.secondary,
        child: Center(
          child: Text(
            label,
            style: AppFonts.heading1.copyWith(color: const Color(0xFFB84B6A)),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Krub',
        fontWeight: FontWeight.w700,
        fontSize: 14,
        color: Colors.black,
      ),
    );
  }
}

class _SelectTile extends StatelessWidget {
  const _SelectTile({required this.valueText, required this.onTap});
  final String? valueText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFECE9E6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF645A80), width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                valueText ?? 'Select',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Krub',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueText == null ? Colors.grey[600] : Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF645A80)),
          ],
        ),
      ),
    );
  }
}

Future<T?> _showRadioSelector<T>({
  required BuildContext context,
  required String title,
  required Map<T, String> options,
  required T? selected,
  void Function(T value)? onChanged,
  Widget Function(BuildContext, void Function(void Function()))? extraFooter,
}) async {
  T? current = selected;
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.white,
    showDragHandle: true,
    isScrollControlled: false,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setStateSheet) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Krub',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
                RadioGroup<T>(
                  groupValue: current,
                  onChanged: (v) {
                    if (v == null) return;
                    setStateSheet(() => current = v);
                    onChanged?.call(v);
                  },
                  child: Column(
                    children: options.entries
                        .map(
                          (e) => InkWell(
                            onTap: () {
                              setStateSheet(() => current = e.key);
                              onChanged?.call(e.key);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Row(
                                children: [
                                  Radio<T>(value: e.key),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      e.value,
                                      style: const TextStyle(
                                        fontFamily: 'Krub',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                if (extraFooter != null) extraFooter(ctx, setStateSheet),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: MainButton(
                    text: 'Done',
                    backgroundColor: const Color(0xFFD8A85B),
                    textColor: Colors.black,
                    width: double.infinity,
                    height: 46,
                    borderRadius: 12,
                    onPressed: () => Navigator.pop(ctx, current),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Future<Set<T>?> _showMultiSelector<T>({
  required BuildContext context,
  required String title,
  required Map<T, String> options,
  required Set<T> initiallySelected,
}) async {
  final selected = {...initiallySelected};
  return showModalBottomSheet<Set<T>>(
    context: context,
    backgroundColor: Colors.white,
    showDragHandle: true,
    builder: (ctx) {
      return SafeArea(
        child: StatefulBuilder(
          builder: (ctx, setStateSheet) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Krub',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
                ...options.entries.map(
                  (e) => CheckboxListTile(
                    value: selected.contains(e.key),
                    onChanged: (v) {
                      setStateSheet(() {
                        if (v == true) {
                          selected.add(e.key);
                        } else {
                          selected.remove(e.key);
                        }
                      });
                    },
                    title: Text(
                      e.value,
                      style: const TextStyle(
                        fontFamily: 'Krub',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: MainButton(
                    text: 'Done',
                    backgroundColor: const Color(0xFFD8A85B),
                    textColor: Colors.black,
                    width: double.infinity,
                    height: 46,
                    borderRadius: 12,
                    onPressed: () => Navigator.pop(ctx, selected),
                  ),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}

/* ===================== Mapper: UI → PATCH ===================== */

HouseRulesPatch _mapEditDataToPatch(EditHouseRuleData d) {
  // Quiet hours start (server expects a single start time string or 'none')
  String? quietStart;
  switch (d.quietHours) {
    case QuietHoursOption.tenToSeven:
      quietStart = '22:00';
      break;
    case QuietHoursOption.elevenToSix:
      quietStart = '23:00';
      break;
    case QuietHoursOption.none:
      quietStart = 'none';
      break;
    case QuietHoursOption.custom:
      quietStart = (d.quietHoursCustom ?? '').trim().isEmpty
          ? null
          : d.quietHoursCustom!.trim();
      break;
    default:
      quietStart = null;
  }

  String? guest;
  switch (d.guestPolicy) {
    case GuestPolicyOption.noOvernight:
      guest = 'No overnight guests';
      break;
    case GuestPolicyOption.max1NightWeek:
      guest = 'Max 1 night/week';
      break;
    case GuestPolicyOption.max3NightsMonth:
      guest = 'Max 3 nights/month';
      break;
    case GuestPolicyOption.noRestriction:
      guest = 'No restriction (notify group)';
      break;
    default:
      guest = null;
  }

  String? cleaning;
  switch (d.cleaningMethod) {
    case CleaningMethodOption.weekly:
      cleaning = 'Weekly rotation';
      break;
    case CleaningMethodOption.biweekly:
      cleaning = 'Bi-weekly rotation';
      break;
    case CleaningMethodOption.assigned:
      cleaning = 'Assigned to specific people';
      break;
    case CleaningMethodOption.flexible:
      cleaning = 'Flexible';
      break;
    default:
      cleaning = null;
  }

  // Responsibilities to a simple comma-separated string (use the visible labels)
  final shared = d.responsibilities.isEmpty
      ? null
      : d.responsibilities.map((e) => responsibilitiesLabels[e]!).join(', ');

  final split =
      (d.splitCosts == null) ? null : (d.splitCosts == SplitCostsOption.equal);

  return HouseRulesPatch(
    quietHoursStart: quietStart,
    guestStayOver: guest,
    handleCleaning: cleaning,
    sharedSpace: shared,
    splitCosts: split,
  );
}
