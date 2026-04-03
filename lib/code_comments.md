This is a comment left during a code review.

**Path:** lib/presentation/screens/profile/widgets/reason_selection_tile.dart
**Line:** 45:90
**Comment:**
	*Logic Error: The `isDestructive` flag is never used, so report reasons rendered with `isDestructive: true` get the same styling as non-destructive reasons. This breaks the expected UI behavior and removes the danger-state visual cue. Use `isDestructive` to switch selected/border/icon/text/check colors to `colorScheme.error` for destructive tiles.

Validate the correctness of the flagged issue. If correct, How can I resolve this? If you propose a fix, implement it and please make it concise.

------------------------

This is a comment left during a code review.

**Path:** lib/data/models/report_unmatch/action_requests.dart
**Line:** 5:16
**Comment:**
	*Logic Error: The unmatch payload model drops the free-text explanation entirely, so the "Other reason" text collected in the unmatch flow can never be serialized and sent to the API. Add an optional `details` field to `UnmatchRequest` and include it in `toJson()` when non-empty.

Validate the correctness of the flagged issue. If correct, How can I resolve this? If you propose a fix, implement it and please make it concise.

------------------------

This is a comment left during a code review.

**Path:** lib/presentation/screens/profile/other_reason_screen.dart
**Line:** 70:70
**Comment:**
	*Logic Error: The bottom button is being offset by keyboard insets manually while `Scaffold` is already configured with `resizeToAvoidBottomInset: true`, so when the keyboard opens the button can be pushed too far upward (double inset effect). Remove the manual `viewInsets.bottom` addition and keep a fixed bottom padding.

Validate the correctness of the flagged issue. If correct, How can I resolve this? If you propose a fix, implement it and please make it concise.

------------------------

This is a comment left during a code review.

**Path:** lib/presentation/screens/profile/widgets/report_unmatch_menu_button.dart
**Line:** 58:58
**Comment:**
	*Logic Error: The menu triggers unmatch/report flows even when `currentUserId` is empty, which can happen from the current caller fallback and leads to invalid API requests (empty user id) when the bottom-sheet actions are submitted. Guard this in `onSelected` so actions are blocked until a valid authenticated user id exists.

Validate the correctness of the flagged issue. If correct, How can I resolve this? If you propose a fix, implement it and please make it concise.

------------------------

This is a comment left during a code review.

**Path:** lib/presentation/screens/profile/viewmodels/report_unmatch_viewmodel.dart
**Line:** 14:14
**Comment:**
	*Logic Error: `build()` uses `ref.read` to capture the repository for `onDispose`, but `read` does not subscribe to provider updates. If `reportUnmatchRepositoryProvider` is recreated (for example when its dependencies change), in-flight requests started from the newer instance will not be cancelled by this disposer callback, leaving stale requests running. Use `ref.watch` here so the viewmodel lifecycle stays tied to the same active repository instance.

Validate the correctness of the flagged issue. If correct, How can I resolve this? If you propose a fix, implement it and please make it concise.

Verify each finding against the current code and only fix it if needed.

In `@lib/data/models/report_unmatch/action_requests.dart` around lines 34 - 40, In
the toJson method of the ActionRequests model, trim the details string before
including it in the serialized map: compute a trimmed version (e.g., let trimmed
= details?.trim()), and change the conditional to include 'details' only when
trimmed is non-null and non-empty, passing trimmed as the value; do not mutate
the original details field elsewhere and keep the rest of toJson unchanged.

------------------------

Verify each finding against the current code and only fix it if needed.

In `@lib/data/models/report_unmatch/reason_option.dart` around lines 20 - 29, The
ReasonOption.fromJson factory currently uses direct casts (e.g., `as String`,
`as int`, `as bool`) which can throw if the API returns different but compatible
types; update ReasonOption.fromJson to defensively parse each field: use
null-safe extraction and type checks, convert non-String values with
`.toString()` for id/type/key/label/icon, parse `ordinal` from num/String using
`.toInt()` or `int.parse()` with fallback, and coerce `active` from
bool/num/String to a boolean (e.g., check for true/1/"true"). Ensure defaults or
throw informative errors for missing required fields so runtime cast failures
are avoided.

------------------------

Verify each finding against the current code and only fix it if needed.

In `@lib/presentation/screens/chat/chat_screen.dart` around lines 91 - 96, The
ReportUnmatchMenuButton is being rendered with
FirebaseAuth.instance.currentUser?.uid ?? '' which may pass an empty
currentUserId into destructive flows; change the conditional that renders
ReportUnmatchMenuButton so it only renders when the authenticated UID is present
and non-empty (e.g., check FirebaseAuth.instance.currentUser?.uid != null &&
FirebaseAuth.instance.currentUser!.uid.isNotEmpty) and still exclude the bot via
widget.otherUserId != ChatConstants.jiffyBotId, and then pass the guaranteed UID
(use the non-null UID variable) into ReportUnmatchMenuButton instead of the
empty-coalesced string.


------------------------

Verify each finding against the current code and only fix it if needed.

In `@lib/presentation/screens/profile/models/report_unmatch_state.dart` at line
21, The current getter isFormValid treats an empty string as valid; update the
validation to ensure selectedReasonKey is non-null and non-empty by checking
both nullity and that selectedReasonKey is not an empty string (e.g., use a
non-empty check on selectedReasonKey in the isFormValid getter) so blank values
are rejected; update the getter implementation that references selectedReasonKey
accordingly.

------------------------

Verify each finding against the current code and only fix it if needed.

In `@lib/presentation/screens/profile/viewmodels/report_unmatch_viewmodel.dart`
around lines 55 - 83, The submitUnmatch method declares an unused parameter
details; remove this parameter from the submitUnmatch signature and any callers
so the function only accepts required String currentUserId and String
matchedUserId, and ensure the UnmatchRequest construction continues to use
userId, matchedUserId, and state.selectedReasonKey! (or if the backend actually
needs details, add a details field to the UnmatchRequest class and wire it into
the request instead of leaving the parameter unused).


------------------------

Verify each finding against the current code and only fix it if needed.

In `@lib/presentation/screens/profile/widgets/reason_selection_tile.dart` around
lines 11 - 12, The ReasonSelectionTile widget currently defines final bool
isDestructive but never uses it, so destructive reasons aren't styled
differently; update the widget's build method in ReasonSelectionTile (the
constructor/property isDestructive) to apply a destructive style when
isDestructive is true — e.g., change the title/text color, leading/trailing icon
color, or subtitle style to the app's destructive color (matching how
report_bottom_sheet.dart passes isDestructive: true) and ensure both the main
build and any alternate rendering path (the other occurrence around lines 69-81)
reference isDestructive so destructive tiles are visually distinct.


------------------------

This is a comment left during a code review.

**Path:** lib/presentation/screens/profile/widgets/report_bottom_sheet.dart
**Line:** 174:174
**Comment:**
	*Logic Error: The free-text reason is never cleared when the user switches away from an "other" reason, so stale text can be submitted for a different reason. Clear the controller when a non-"other" reason is selected to keep the submitted payload consistent with the current selection.

Validate the correctness of the flagged issue. If correct, How can I resolve this? If you propose a fix, implement it and please make it concise.


------------------------


This is a comment left during a code review.

**Path:** lib/presentation/screens/profile/widgets/report_bottom_sheet.dart
**Line:** 201:201
**Comment:**
	*Possible Bug: The cancel action stays active during submission, allowing users to close the sheet while the request is still in flight, which can abort the operation when the provider is disposed. Disable cancel while submitting so the report/unmatch request can complete reliably.

Validate the correctness of the flagged issue. If correct, How can I resolve this? If you propose a fix, implement it and please make it concise.


------------------------

This is a comment left during a code review.

**Path:** lib/data/repositories/report_unmatch_repository.dart
**Line:** 65:65
**Comment:**
	*Logic Error: The method named as a combined action only sends the report request and never calls the unmatch endpoint, so users can remain matched after a successful "report and unmatch" flow. Execute both API operations in this method so behavior matches the caller/UI contract.

Validate the correctness of the flagged issue. If correct, How can I resolve this? If you propose a fix, implement it and please make it concise.


------------------------

This is a comment left during a code review.

**Path:** lib/data/repositories/report_unmatch_repository.dart
**Line:** 94:94
**Comment:**
	*Possible Bug: This provider is auto-disposed by default, and the viewmodel uses `ref.read` repeatedly plus captures one instance for disposal callbacks, which can lead to different repository instances and broken cancellation behavior for in-flight requests. Keep this provider alive for the screen lifecycle so all calls share one repository/cancel registry instance.

Validate the correctness of the flagged issue. If correct, How can I resolve this? If you propose a fix, implement it and please make it concise.
