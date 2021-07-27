import pytest
from selenium.webdriver.common.by import By
from selenium.webdriver.remote.webdriver import WebDriver
from selenium.webdriver.remote.webelement import WebElement


@pytest.mark.nondestructive
def test_header_should_be_visible(selenium: WebDriver, base_url: str):
    selenium.get(base_url)
    header: WebElement = selenium.find_element(By.CSS_SELECTOR, "h1")
    assert header.text == "Application"
