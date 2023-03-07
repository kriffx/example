*** Settings ***
Documentation    Test scenarios for example.


*** Variables ***
${URL}    https://the-internet.herokuapp.com/javascript_alerts

*** Test Cases ***
Click for JS Alert
    Open Browser    browser=chrome    options=add_argument("--disable-extensions");add_argument("--disable-gpu");add_argument("--no-sandbox")
    Maximize Browser Window
    Go To    url=${URL}
    Wait Until Element Is Visible    locator=tag:body
    Title Should Be    title=The Internet 2
    Click Button    locator=xpath://*[@id="content"]/div/ul/li[1]/button
    Handle Alert    action=ACCEPT
    Wait Until Element Contains    locator=id:result    text=You successfully clicked an alert
    Close Browser

Click for JS Confirm
    Open Browser    browser=chrome    options=add_argument("--disable-extensions");add_argument("--disable-gpu");add_argument("--no-sandbox")
    Maximize Browser Window
    Go To    url=${URL}
    Wait Until Element Is Visible    locator=tag:body
    Title Should Be    title=The Internet
    Click Button    locator=xpath://*[@id="content"]/div/ul/li[2]/button
    Handle Alert    action=ACCEPT
    Wait Until Element Contains    locator=id:result    text=You clicked: Ok
    Close Browser

