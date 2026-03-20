This is a comment left during a code review.

**Path:** lib/presentation/screens/home/home_screen.dart
**Line:** 591:595
**Comment:**
	*Possible Bug: The loading dialog dismissal now depends on `mounted`, so if the widget is disposed while the async fetch runs, the spinner route can remain stuck on the root navigator. Capture the root navigator before awaiting and always pop it safely when the call finishes.

Validate the correctness of the flagged issue. If correct, How can I resolve this? If you propose a fix, implement it and please make it concise.

----------------------

This is a comment left during a code review.

**Path:** lib/presentation/screens/home/home_screen.dart
**Line:** 733:737
**Comment:**
	*Possible Bug: This duplicate async profile flow has the same lifecycle issue: when the widget unmounts during the fetch, the loading dialog is not dismissed because pop is gated by `mounted`. Capture and reuse the root navigator so the dialog is always cleaned up.

Validate the correctness of the flagged issue. If correct, How can I resolve this? If you propose a fix, implement it and please make it concise.

----------------------

This is a comment left during a code review.

**Path:** lib/presentation/screens/home/widgets/first_time_story_prompt_sheet.dart
**Line:** 76:79
**Comment:**
	*Possible Bug: This handler pops the bottom sheet and then immediately uses the same sheet `BuildContext` for navigation. After `pop`, that context can be deactivated, which can trigger runtime ancestor lookup/navigation errors. Capture a stable navigator context before popping and navigate with that instead.

Validate the correctness of the flagged issue. If correct, How can I resolve this? If you propose a fix, implement it and please make it concise.

----------------------

Verify each finding against the current code and only fix it if needed.

In `@lib/presentation/screens/home/home_screen.dart` around lines 598 - 603,
Remove the redundant useSafeArea parameter from the two showModalBottomSheet
calls that present ProfileViewScreen (which already wraps its UI in a SafeArea).
Locate the two invocations of showModalBottomSheet in home_screen.dart and
delete the useSafeArea: true argument from each call so the inner
ProfileViewScreen's SafeArea handles insets exclusively.

----------------------

Verify each finding against the current code and only fix it if needed.

In `@lib/presentation/screens/home/widgets/first_time_story_prompt_sheet.dart`
around lines 10 - 16, The sheet is using the sheet's (deactivated) context for
navigation after pop; fix by capturing a stable parent context before calling
showModalBottomSheet in FirstTimeStoryPromptSheet.show (e.g. final parentContext
= context) and use that parentContext for any navigation after dismissing the
sheet (the primary CTA logic inside FirstTimeStoryPromptSheet should call
Navigator.pop(sheetContext) or Navigator.of(sheetContext).pop(), then call
GoRouter.of(parentContext).pushRoute(...) or similar using parentContext).
Update references in the primary CTA handler to use the captured parentContext
instead of the sheet's builder context so ancestor lookups (pushRoute) run
against a live context.