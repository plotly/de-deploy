printf '#!/bin/bash\necho username=$DE_USERNAME\necho password=$DE_PASSWORD' >> helper-script.sh
git config --global credential.helper "/bin/bash $(pwd)/helper-script.sh"
git config --global user.email '<>' # Leave email blank
git config --global user.name "Github Automatic Deployer"
git config --global protocol.version 0