#include <Cocoa/Cocoa.h>
#import "PasswordHelper.h"

/*! The ASKPASS program for ssh (and for rsync via ssh). 
 
 When ssh (or rsync) needs a response from the user it asks this program instead (provided that ssh or rsync have been started with the appropriate environment variables set).
 
 Sometimes ssh will ask for a password, but if a connection is being established to a server for the first time it will ask whether the user wants to add the host to the list of known hosts (in that case the required response is "yes"). This program figures out what the correct response is and supplies it. 
 
 If a password for the user/hostname combination is not available this program will prompt the user for a password.
 
*/

void wakeUpGitifier(NSInteger pid) {
  if (pid > 0) {
    ProcessSerialNumber psn;
    OSStatus status = GetProcessForPID(pid, &psn);
    if (status == 0) {
      SetFrontProcess(&psn);
    }
  }
}

int main() {
  @autoreleasepool {
    // Get basic information from environment variables that were set along with the NSTask itself.
    // We need this info in order to get the correct password from the security keychain
    NSDictionary *dict = [[NSProcessInfo processInfo] environment];
    NSString *usernameString = [dict valueForKey: @"AUTH_USERNAME"];
    NSString *hostnameString = [dict valueForKey: @"AUTH_HOSTNAME"];
    NSString *gitifierPid = [dict valueForKey: @"GITIFIER_PID"];

    NSInteger pid = (gitifierPid) ? [gitifierPid integerValue] : -1;

    /*
      The arguments array should contain three elements. The second element is a string which we can use to determine
      the context in which this program was invoked. This string is either a message prompting for a yes/no or a message
      prompting for a password. We check it and supply the right response.
    */

    NSArray *argumentsArray = [[NSProcessInfo processInfo] arguments];
    if (argumentsArray.count >= 2) {
      NSRange yesnoRange = [[argumentsArray objectAtIndex: 1] rangeOfString: [NSString stringWithFormat: @"(yes/no)"]];

      // If the string yes/no was found in the arguments array then we need to return a YES instead of password
      if (yesnoRange.location != NSNotFound) {
        printf("%s", "YES");
        return 0;
      }
    }

    if (usernameString && hostnameString) {
      // First try to get the password from the keychain
      NSString *pStr = [PasswordHelper passwordForHost: hostnameString user: usernameString];
      if (!pStr) {
        // No password was found in the keychain so we should prompt the user for it.
        wakeUpGitifier(pid);
        NSArray *promptArray = [PasswordHelper promptForPassword: hostnameString user: usernameString];
        NSInteger returnCode = [[promptArray objectAtIndex: 1] intValue];

        if (returnCode == 0) { // Found a valid password entry
          // Set the new password in the keychain.
          [PasswordHelper setPassword: [promptArray objectAtIndex: 0] forHost: hostnameString user: usernameString];
          pStr = [promptArray objectAtIndex: 0];
          wakeUpGitifier(pid);
        } else if (returnCode == 1) { // User cancelled so we'll just abort
          // We return a non zero exit code here which should cause ssh to abort
          wakeUpGitifier(pid);
          return 1;
        }
      }

      void *pword = (void *) [pStr UTF8String];
      printf("%s", (char *) pword);
      return 0;
    }

    // If we get to here something has gone wrong. Just return 1 to indicate failure
    return 1;
  }
}
