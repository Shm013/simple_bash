find * | xargs -I '{}' sed -ri 's/ +(\r)?$/\1/g' {}
