The following is a screenshot of the workflow setup to run one of the two .ps1 scripts on our managed Windows devices. 

---

![image](https://github.com/user-attachments/assets/10a367ba-c1d7-4f46-bd08-d804180047c4)

  
---

## Configuration
  
  - This script is scheduled to run on a weekly basis to ensure complete coverage
  - The script first looks at the system tags we have assigned in VSA X. 
    - If the device has the USB allow tag, then it will run the script to Enable access.
    - If the device does not have the tag, then it will run the script to Disable access.
