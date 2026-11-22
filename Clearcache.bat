@echo off
@title !Clearcache
rd /s /q "%CD%\cache"
rd /s /q "%CD%\crashes"
rd /s /q "%CD%\db"

@pause