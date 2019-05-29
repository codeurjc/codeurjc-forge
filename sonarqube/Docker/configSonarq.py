#!/usr/bin/python3

from selenium import webdriver
from selenium.webdriver.common.keys import Keys
import time
import os

driver = webdriver.Firefox()
sutURL = 'http://' + os.environ['APP_URL'] + ':9000/sessions/new'
driver.get(sutURL)

token_file = '/workdir/SonarQubeToken.txt'
new_pass = os.environ['ADMIN_PWD']

time.sleep(2)

elem = driver.find_element_by_id('login')
elem.send_keys('admin')
elem.send_keys(Keys.TAB)

elem = driver.find_element_by_id('password')
elem.send_keys('admin')
elem.send_keys(Keys.RETURN)

time.sleep(2)

elem = driver.find_element_by_class_name('input-large').send_keys('Jenkins')
time.sleep(1)
elem = driver.find_element_by_xpath("//button[text()=\'Generate\']").send_keys(Keys.RETURN)

time.sleep(2)

token = driver.find_element_by_class_name('spacer-right').text

file = open(token_file,'w')
file.write(token)

print('Changing Admin Password')
sutURL = 'http://' + os.environ['APP_URL'] + ':9000/account/security'
driver.get(sutURL)

time.sleep(2)

elem = driver.find_element_by_class_name('js-skip').send_keys(Keys.ESCAPE)

time.sleep(2)

elem = driver.find_element_by_id('old_password').send_keys('admin')
elem = driver.find_element_by_id('password').send_keys(new_pass)
elem = driver.find_element_by_id('password_confirmation').send_keys(new_pass)
elem = driver.find_element_by_id('change-password').click()

driver.quit()