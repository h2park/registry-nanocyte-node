FROM node:5-onbuild
MAINTAINER Octoblu <docker@octoblu.com>
EXPOSE 80
ENV PORT 80

CMD ["npm", "start"]
