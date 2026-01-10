In @lib/core/services/home_service.dart around lines 144-164, The current
grouping logic for stories (variable storiesByUser in the loop) only compares
createdAt when both existingCreatedAt and currentCreatedAt are ints, which
silently ignores ISO String timestamps; add a small helper like
_parseTimestamp(dynamic) that converts int to itself and parses String via
DateTime.tryParse(...).millisecondsSinceEpoch (returning null on failure), then
use it to obtain existingTs and currentTs and compare those ints to decide
whether to replace storiesByUser[userId] with the more recent story.

In @lib/presentation/screens/home/home_screen.dart around lines 317-360, The
call to StoryApiHelpers.groupStoriesByUser(allUserStories, currentUser.uid) can
throw if no stories match the uid; wrap this call in a try-catch and/or
defensively filter allUserStories by story.userId == currentUser.uid before
grouping, then handle both errors and empty results by performing the existing
fallback navigation (the else branch behavior). Specifically, catch
ArgumentError (and any Exception), fall back to using allUserStories in the
navigation payload, and keep the existing sheetContext pop +
WidgetsBinding.instance.addPostFrameCallback/stableContext navigation logic
unchanged.

In @lib/presentation/screens/stories/story_api_helpers.dart around lines 70-81,
The call sites that invoke StoryApiHelpers.groupStoriesByUser should handle the
ArgumentError thrown when no stories match the provided userId: wrap the calls
to groupStoriesByUser(userStories, userId) (the two places that currently check
.isNotEmpty before calling) in a try-catch and catch ArgumentError (or on
ArgumentError) and handle it (e.g., show an error/toast, skip navigation, or use
a fallback grouped story); alternatively you can change groupStoriesByUser to
return a nullable Story? or an empty sentinel instead of throwing and update
callers accordingly—pick one approach and apply it to both call sites that
currently call groupStoriesByUser.

This is a comment left during a code review.

**Path:** lib/core/services/home_service.dart
**Line:** 138:138
**Comment:**
	*Type Error: `match['uid']` comes from dynamic JSON and is cast directly to `String?`, which will throw a runtime type error if the backend ever returns a non-string UID (e.g., an int); this is inconsistent with other code (like `MatchesViewModel`) that already uses `.toString()` for the same field and can cause crashes when building the matches map.

Validate the correctness of the flagged issue. If correct, How can I resolve this? If you propose a fix, implement it and please make it concise.

This is a comment left during a code review.

**Path:** lib/core/services/home_service.dart
**Line:** 157:159
**Comment:**
	*Logic Error: When grouping stories per user, the logic to keep only the most recent story compares `createdAt` values only when both are integers, ignoring the case where the API returns ISO8601 strings, so for string timestamps you will keep an arbitrary (likely first) story instead of the latest one, breaking the intended behavior.

Validate the correctness of the flagged issue. If correct, How can I resolve this? If you propose a fix, implement it and please make it concise.

This is a comment left during a code review.

**Path:** lib/presentation/screens/home/home_screen.dart
**Line:** 324:346
**Comment:**
	*Logic Error: The grouping helper explicitly throws an ArgumentError when no stories are found for the given userId, but here you call it with the entire `allUserStories` list without first ensuring any of those stories actually belong to the current user; if the backend ever returns stories with mismatched or missing `userId` values, tapping "View Stories" will crash the app instead of falling back to the non-grouped behavior.

Validate the correctness of the flagged issue. If correct, How can I resolve this? If you propose a fix, implement it and please make it concise.

This is a comment left during a code review.

**Path:** lib/presentation/screens/stories/story_api_helpers.dart
**Line:** 91:100
**Comment:**
	*Logic Error: The grouped story's expiry time is taken from the last story after sorting by `createdAt`, which assumes that the most recently created story also expires last; if any earlier story has a later `expiresAt` (or a later non-null expiry mixed with nulls), the combined story will incorrectly disappear before all of its contents expire, so the expiry should be computed as the maximum non-null `expiresAt` across all user stories instead of relying on the last item.

Validate the correctness of the flagged issue. If correct, How can I resolve this? If you propose a fix, implement it and please make it concise.

This is a comment left during a code review.

**Path:** lib/presentation/screens/stories/story_viewer_screen.dart
**Line:** 355:355
**Comment:**
	*Logic Error: The pause/loading indicator comment says it "shows play icon when paused, hourglass when loading", but the icon currently depends only on `_isImageLoaded`; in the state where the user has explicitly paused while the image is still loading, it incorrectly shows the hourglass instead of a play icon, giving confusing feedback about the current state.

Validate the correctness of the flagged issue. If correct, How can I resolve this? If you propose a fix, implement it and please make it concise.

This is a comment left during a code review.

**Path:** lib/presentation/screens/stories/story_viewer_screen.dart
**Line:** 664:681
**Comment:**
	*Logic Error: When a story is paused, the progress bar's animation controller is stopped with the default `canceled: true`, which leaves its `status` as `AnimationStatus.forward`; on resume the code checks `if (_controller.status != AnimationStatus.forward)` before calling `forward()`, so the animation never restarts and the progress bar stays frozen instead of resuming.

Validate the correctness of the flagged issue. If correct, How can I resolve this? If you propose a fix, implement it and please make it concise.

