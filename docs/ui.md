# The window and its tabs

Each tab is data: `src/2-ui/<Tab>.ps1` defines a `TAB_<NAME>` hashtable of cards, and each card
lists its items — buttons with their `Action`, their options and an optional centred "Start
after download" checkbox (`StartAfterDownload`), and standalone checkboxes. `New-Tab`
(`src/1-components/Tab.ps1`) renders a definition through the component functions, which add
to the panel they are given and return what they made. It rejects unknown keys, a missing
`Action` or `Name` and duplicate names, puts every checkbox into `$CHECKBOXES` under its `Name`,
and every button given a `Name` into `$BUTTONS`.

## Layout

- Placement follows from the definition: a button's options join its "Start after download"
  group when it has one and sit in the card otherwise, and every button after a card's first
  item is spaced from what comes before it.
- The window's height follows from the tabs too: once laid out, before it is drawn,
  `Set-WindowHeight` makes it tall enough for the tallest tab to show without scrolling (as far
  as the screen allows), so adding, moving or removing cards needs no size change.
- A change to the components, the renderer, the definitions' layout or `Form.ps1` that should
  not change how the window looks is checked with `.\test-visual.bat`: it renders every tab in
  the light, dark and high contrast themes from `HEAD` and from the working tree, and compares
  them pixel for pixel (differences land in `build/ui-snapshots/diff`).

## Handlers and async operations

- Handlers read checkboxes at click time (`$CHECKBOXES.StartVentoy.IsChecked`). A checkbox that
  enables others has `OnClick = { Set-CheckboxState -Control $this -Dependant $CHECKBOXES.<Name> }`.
- Only one async operation runs at a time. `New-Tab` registers every button whose `Action`
  calls `Start-AsyncOperation` (`Register-AsyncButton`); while an operation runs, all of them
  are disabled except the one that started it, which turns into its Cancel button until the
  cancellation is under way. A handler that enables or disables such a button for a reason of
  its own, such as nothing being selected to apply, goes through
  `Set-ButtonEnabled $BUTTONS.<Name>`, never `IsEnabled`, so that the state survives an
  operation.
- An operation reaches the window only through
  `Invoke-OnDispatcher 'Command-Name' @{ Parameter = $Value }`, which runs that function on the
  UI thread through a delegate the UI thread's runspace created, so only data crosses threads.
  Never hand a dispatcher a script block from the async runspace: once the operation is being
  cancelled, running it waits for that runspace while the operation waits for the UI thread, and
  the window freezes. `Invoke-OnDispatcher.Tests.ps1` fails on any other code that calls into a
  dispatcher. The functions that touch the window (`Add-FormLogEntry`, `Set-ProgressBarValue`,
  `Set-FormIcon`) run only that way.
- `Start-AsyncOperation` copies function bodies into its runspace, not the handler's scope, so
  an operation gets only what is passed with `-Variables` (and the app-wide variables it
  injects). The app's enums (`[LogLevel]`, `[IconName]`) resolve there only inside those
  functions, not in the operation's own script block. `src/2-ui/Tabs.Tests.ps1` fails on a
  variable that is not passed, on a checkbox or a named button that is read but not defined, or
  defined but never read, and on a button that starts an operation without being registered.
