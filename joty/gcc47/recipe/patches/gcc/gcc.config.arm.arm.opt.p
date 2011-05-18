Index: gcc/config/arm/arm.opt
===================================================================
--- gcc/config/arm/arm.opt	(revision 173874)
+++ gcc/config/arm/arm.opt	(working copy)
@@ -42,6 +42,9 @@
 Enum(arm_abi_type) String(iwmmxt) Value(ARM_ABI_IWMMXT)
 
 EnumValue
+Enum(arm_abi_type) String(apcs-32) Value(ARM_ABI_APCS32)
+
+EnumValue
 Enum(arm_abi_type) String(aapcs-linux) Value(ARM_ABI_AAPCS_LINUX)
 
 mabort-on-noreturn
