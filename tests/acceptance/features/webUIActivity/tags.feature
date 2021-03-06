@webUI @insulated @disablePreviews
Feature: Tag files/folders activities
  As a user
  I want to be able to see history of the files and folders that I have tagged
  So that I know what happened in my cloud storage

  Scenario Outline: Adding a tag on a file/folder should be listed on the activity list
    Given user "user0" has been created with default attributes
    And user "user0" has logged in using the webUI
    And user "user0" has created a "normal" tag with name "lorem"
    # <filepath> already has an ending slash('/')
    And user "user0" has added tag "lorem" to file "<filepath><filename>"
    When the user browses to the activity page
    Then the activity number 1 should contain message "You assigned system tag lorem to <filename>" in the activity page
    Examples:
      | filepath                            | filename            |
      | /                                   | lorem.txt           |
      | simple-folder/                      | testapp.zip         |
      | /                                   | 0                   |
      | 'single'quotes/                     | simple-empty-folder |
      | 0/                                  | lorem.txt           |
      | 'single'quotes/simple-empty-folder/ | for-git-commit      |

  Scenario Outline: Adding a tag on the shared file/folder should be listed on the activity list
    Given these users have been created with default attributes:
      | username |
      | user0    |
      | user1    |
    And group "group1" has been created
    And user "user0" has been added to group "group1"
    And user "user1" has been added to group "group1"
    And user "user0" has created a "normal" tag with name "lorem"
    And user "user0" has shared file "<filename>" with group "group1"
    And user "user0" has added tag "lorem" to file "<filename>"
    And user "user0" has logged in using the webUI
    When the user browses to the activity page
    Then the activity number 1 should have message "You assigned system tag lorem to <filename>" in the activity page
    And the activity number 2 should have message "You shared <filename> with group group1" in the activity page
    When the user re-logs in as "user1" using the webUI
    And the user browses to the activity page
    Then the activity number 1 should contain message "User Zero assigned system tag lorem to <filename>" in the activity page
    And the activity number 2 should contain message "User Zero shared <filename> with you" in the activity page
    Examples:
      | filename      |
      | lorem.txt     |
      | simple-folder |

  Scenario Outline: tagging activity before sharing should not be listed for the share receiver.
    Given these users have been created with default attributes:
      | username |
      | user0    |
      | user1    |
    And group "group1" has been created
    And user "user0" has been added to group "group1"
    And user "user1" has been added to group "group1"
    And user "user0" has created a "normal" tag with name "lorem"
    And user "user0" has added tag "lorem" to file "<filename>"
    And user "user0" has shared entry "<filename>" with group "group1"
    And user "user0" has logged in using the webUI
    When the user browses to the activity page
    Then the activity number 1 should have message "You shared <filename> with group group1" in the activity page
    And the activity number 2 should have message "You assigned system tag lorem to <filename>" in the activity page
    When the user re-logs in as "user1" using the webUI
    And the user browses to the activity page
    Then the activity number 1 should contain message "User Zero shared <filename> with you" in the activity page
    And the activity should not have any message with keyword "system tag lorem"
    Examples:
      | filename      |
      | lorem.txt     |
      | simple-folder |

  Scenario Outline: Activity for tagging a shared file/folder by sharee should be listed for sharer as well
    Given user "user0" has been created with default attributes
    And user "user1" has been created with default attributes and without skeleton files
    And group "group1" has been created
    And user "user0" has been added to group "group1"
    And user "user1" has been added to group "group1"
    And user "user0" has shared file "<filename>" with group "group1"
    And user "user1" has created a "normal" tag with name "lorem"
    And user "user1" has added tag "lorem" to file "<filename>"
    And user "user0" has logged in using the webUI
    When the user browses to the activity page
    Then the activity number 1 should contain message "User One assigned system tag lorem to <filename>" in the activity page
    And the activity number 2 should have message "You shared <filename> with group group1" in the activity page
    When the user re-logs in as "user1" using the webUI
    And the user browses to the activity page
    Then the activity number 1 should have message "You assigned system tag lorem to <filename>" in the activity page
    And the activity number 2 should contain message "User Zero shared <filename> with you" in the activity page
    Examples:
      | filename      |
      | lorem.txt     |
      | simple-folder |

  Scenario: Activity for tagging a reshared folder by sharee should be listed for original sharer as well
    Given user "user0" has been created with default attributes
    And user "user1" has been created with default attributes and without skeleton files
    And user "user2" has been created with default attributes and without skeleton files
    And group "group1" has been created
    And user "user0" has been added to group "group1"
    And user "user1" has been added to group "group1"
    And user "user0" has shared folder "simple-folder/simple-empty-folder" with group "group1"
    And user "user1" has shared folder "simple-empty-folder" with user "user2"
    And user "user2" has created a "normal" tag with name "simple"
    And user "user2" has added tag "simple" to folder "simple-empty-folder"
    And user "user0" has logged in using the webUI
    When the user browses to the activity page
    Then the activity number 1 should contain message "User Two assigned system tag simple to simple-empty-folder" in the activity page
    And the activity number 2 should have a message saying that user "User One" has shared "simple-empty-folder" with user "User Two"
    And the activity number 3 should have message "You shared simple-empty-folder with group group1" in the activity page
    When the user re-logs in as "user1" using the webUI
    And the user browses to the activity page
    Then the activity number 1 should contain message "User Two assigned system tag simple to simple-empty-folder" in the activity page
    And the activity number 2 should have a message saying that you have shared folder "simple-empty-folder" with user "User Two"
    And the activity number 3 should have a message saying that user "User Zero" has shared "simple-empty-folder" with you
    When the user re-logs in as "user2" using the webUI
    And the user browses to the activity page
    Then the activity number 1 should have message "You assigned system tag simple to simple-empty-folder" in the activity page
    And the activity number 2 should have a message saying that user "User One" has shared "simple-empty-folder" with you
    And the activity should not have any message with keyword "User Zero"
