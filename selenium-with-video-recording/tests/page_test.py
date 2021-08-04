import time

from selenium.webdriver.common.by import By
from selenium.webdriver.remote.webdriver import WebDriver
from selenium.webdriver.remote.webelement import WebElement


def test_header_text_should_start_with_20(selenium: WebDriver, base_url: str):
    selenium.get(base_url)
    header: WebElement = selenium.find_element(By.CSS_SELECTOR, "#header")

    # For making video longer
    time.sleep(10)

    assert header.text.startswith("20")
