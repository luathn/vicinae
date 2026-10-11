#pragma once
#include <QtGlobal>

// The launcher is a non-activating panel, so macOS keeps the frontmost app's input
// source while it is open. We give it its own: the one last used in the launcher is
// selected on show, and the previous one is restored on hide.
namespace InputSource {

#ifdef Q_OS_MACOS
void launcherShown();
void launcherHidden();
#else
inline void launcherShown() {}
inline void launcherHidden() {}
#endif

} // namespace InputSource
