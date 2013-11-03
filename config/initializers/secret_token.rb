# the secret token should not be check into the repository. For dev and
# test mode a dummy token suffices. In production either
#      export SECRET_TOKEN="random chars here"
# or put it into
#      apg -a 1 -n 1 -m 60 -x 60 -M cLn > .SECRET_TOKEN
# the .SECRET_TOKEN file. The token should not be changed regularly.

Keks::Application.config.secret_token = Rails.env.production? ? ENV['SECRET_TOKEN'] : "x"*30
