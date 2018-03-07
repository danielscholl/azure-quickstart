## Instructions on ensuring AD Group can access RDP


1. In Group Policy Management Console (GPMC.MSC) select Computer Configuration\Windows Settings\Security Settings\Restricted Groups\

1. Right-click Restricted Groups and then click Add Group.

1. Click the Browse button, type Remote and click the Check Names and you should see REMOTE DESKTOP USERS come up.

1. Click OK in the Add Groups dialog.

1. Click Add beside the MEMBERS OF THIS GROUP box then click Browse.

1. Type the name of the domain group, then click the Check Names button, then click OK to close this box.

1. Click OK to close this box  which will complete the addition of the domain group to the Remote Desktop Users group.

1. Go to your PC and in an elevated command prompt type GPUPDATE /FORCE to refresh the GPolicy on your PC

1. Verify that the group  has been added to under the SELECT USERS button on the REMOTE tab of the PC’s SYSTEM PROPERTIES.