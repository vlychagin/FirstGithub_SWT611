# FirstGithub_SWT611

## Директивы для отправки первого коммита на удаленный репозиторий

    echo "# FirstGithub_SWT611" >> README.md
    git init
    git add README.md
    git commit -m "first commit"
    git branch -M master
    git remote add origin https://github.com/vlychagin/FirstGithub_SWT611.git
    git push -u origin master

## Для последуюущих коммитов

    git add .
    git commit -m'комментарий'
    git push
