# autogit
Bash script which enables users to download the latest release from their favourite Github tool. The script downloads the archive file, extracts it and moves it to the /opt/ folder. Afterwards the downloaded archive files are removed from the current working folder. The goal is to make the installment of (mainly cybersecurity related tools) projects easier.

# Install & Run
```sh
git clone X
cd X
sudo bash autogit.sh -u "https://api.github.com/repos/anotheruser/anotherproject/releases"
```

<img src="https://github.com/bl13pbl03p/autogit/assets/22095577/7c94fa24-543b-493d-b3db-f5a9d9a25c53" width=700px height=230px>

# To do
- [x]  Build initial script
- [ ]  Make compatible for more archive files
