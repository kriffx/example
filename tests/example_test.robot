*** Settings ***
Documentation    Test scenarios for example.

Library    SeleniumLibrary

*** Variables ***
${URL}=    https://the-internet.herokuapp.com/javascript_alerts

*** Test Cases ***
Click for JS Alert
    [Documentation]    Click for JS Alert and show message successfully
    [Tags]    js_alert
	${PAGE_TITLE}=    Set Variable    The Internet
    Open Browser    browser=headlesschrome    options=add_argument("--disable-extensions");add_argument("--headless");add_argument("--disable-gpu");add_argument("--no-sandbox")
    Maximize Browser Window
    Go To    url=${URL}
    Wait Until Element Is Visible    locator=tag:body
    Title Should Be    title=${page_title}
    Click Button    locator=xpath://*[@id="content"]/div/ul/li[1]/button
    Handle Alert    action=ACCEPT
    Wait Until Element Contains    locator=id:result    text=You successfully clicked an alert
    Close Browser

Click for JS Confirm
    [Documentation]    Click for JS Confirm and show message Ok
    [Tags]    js_confirm
	${PAGE_TITLE}=    Set Variable    The Internet
    Open Browser    browser=headlesschrome    options=add_argument("--disable-extensions");add_argument("--headless");add_argument("--disable-gpu");add_argument("--no-sandbox")
    Maximize Browser Window
    Go To    url=${URL}
    Wait Until Element Is Visible    locator=tag:body
    Title Should Be    title=${PAGE_TITLE}
    Click Button    locator=xpath://*[@id="content"]/div/ul/li[2]/button
    Handle Alert    action=ACCEPT
    Wait Until Element Contains    locator=id:result    text=You clicked: Ok
    Close Browser