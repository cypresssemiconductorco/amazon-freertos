## Cloning
This repo uses [Git Submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules) to bring in dependent components.

Note: If you download the ZIP file provided by GitHub UI, you will not get the contents of the submodules. (The ZIP file is also not a valid git repository)

To clone using HTTPS:
```
git clone https://github.com/aws/amazon-freertos.git --recurse-submodules
```
Using SSH:
```
git clone git@github.com:aws/amazon-freertos.git --recurse-submodules
```

If you have downloaded the repo without using the `--recurse-submodules` argument, you need to run:
```
git submodule update --init --recursive
```

## Important branches to know
master            --> Development is done continuously on this branch  
release           --> Fully tested released source code  
release-candidate --> Preview of upcoming release  
feature/*         --> Alpha/beta of an upcoming feature  

## Getting Started

For more information on Amazon FreeRTOS, refer to the [Getting Started section of Amazon FreeRTOS webpage](https://aws.amazon.com/freertos).

To directly access the **Getting Started Guide** for supported hardware platforms, click the corresponding link in the Supported Hardware section below.

For detailed documentation on Amazon FreeRTOS, refer to the [Amazon FreeRTOS User Guide](https://aws.amazon.com/documentation/freertos).

For support or more detailed information on Cypress Boards, refer to the [Cypress Community Forum](https://community.cypress.com/welcome)

## Supported Hardware

The following MCU boards are supported for Amazon FreeRTOS:
1. **Cypress CY8CPROTO-062-4343W** - [Cypress PSoC 6 Wi-Fi BT Prototyping Kit](http://www.cypress.com/CY8CPROTO-062-4343W).
    * [Getting Started Guide](https://community.cypress.com/community/modustoolbox-amazon-freertos-sdk)
    * IDEs: [ModusToolbox](https://community.cypress.com/community/modustoolbox-amazon-freertos-sdk)
2. **Cypress CY8CKIT-062-WIFI-BT** - [Cypress PSoC 6 WiFi-BT Pioneer Kit](https://www.cypress.com/CY8CKIT-062-WiFi-BT).
    * [Getting Started Guide](https://community.cypress.com/community/modustoolbox-amazon-freertos-sdk)
    * IDEs: [ModusToolbox](https://community.cypress.com/community/modustoolbox-amazon-freertos-sdk)
3. **Cypress CYW54907** - [Cypress CYW954907AEVAL1F Evaluation Kit](https://www.cypress.com/documentation/development-kitsboards/cyw954907aeval1f-evaluation-kit)
    * [Getting Started Guide](https://docs.aws.amazon.com/freertos/latest/userguide/getting_started_cypress_54.html)
    * IDE: [WICED Studio](https://community.cypress.com/community/wiced-wifi)
4. **Cypress CYW43907** - [Cypress CYW943907AEVAL1F Evaluation Kit](https://www.cypress.com/documentation/development-kitsboards/cyw943907aeval1f-evaluation-kit)
    * [Getting Started Guide](https://docs.aws.amazon.com/freertos/latest/userguide/getting_started_cypress_43.html)
    * IDE: [WICED Studio](https://community.cypress.com/community/wiced-wifi)


## amazon-freeRTOS/projects
The ```./projects``` folder contains the IDE test and demo projects for Cypress boards. The majority of boards can be built with both IDE and cmake (there are some exceptions!). Please refer to the Getting Started Guides above for board specific instructions.
