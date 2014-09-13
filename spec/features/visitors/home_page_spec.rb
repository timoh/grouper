# Feature: Home page
#   As a visitor
#   I want to visit a home page
#   So I can learn more about the website
feature 'Home page' do

  # Scenario: Visit the home page
  #   Given I am a visitor
  #   When I visit the home page
  #   Then I see "Welcome"
  scenario 'show the raw CSV printout' do
    visit root_path
    expect(page).to have_content 'Male'
    expect(page).to have_content 'Female'
    expect(page).to have_content 'Master'
    expect(page).to have_content 'Bachelor'
  end

end
