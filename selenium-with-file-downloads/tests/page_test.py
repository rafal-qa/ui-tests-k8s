import os
import time

import requests
from selenium.webdriver.common.by import By
from selenium.webdriver.remote.webdriver import WebDriver
from selenium.webdriver.remote.webelement import WebElement


downloads_api_url = os.getenv("DOWNLOADS_API_URL")


def test_header_should_be_visible(selenium: WebDriver, base_url: str):
    selenium.get(base_url)
    header: WebElement = selenium.find_element(By.CSS_SELECTOR, "h1")

    assert header.text == "Application"


def test_file_should_be_downloaded(selenium: WebDriver, base_url: str):
    selenium.get(base_url)
    link: WebElement = selenium.find_element(By.CSS_SELECTOR, "a")
    link.click()
    wait_for_file("file.bin", 13)

    assert get_file_contents("file.bin") == "file contents"


def wait_for_file(name: str, size: int):
    for _ in range(1, 5):
        if check_file_exists(name, size):
            return
        time.sleep(1)
    raise TimeoutError(f"File '{name}' with size '{size}' was not found")


def check_file_exists(name: str, size: int):
    r = requests.get(downloads_api_url, timeout=10)
    files_list = r.json()
    for item in files_list:
        if item["name"] == name and item["size"] == size:
            return True
    return False


def get_file_contents(name: str):
    r = requests.get(f"{downloads_api_url}/{name}", timeout=10)
    # For simplicity assume that it's always a text file (not binary)
    return r.text
