FROM cloudfoundry/cflinuxfs3
ADD post-configuration.sh ./
ADD tag ./
ADD switch-versions ./

RUN cp tag /etc/tag && \
bash post-configuration.sh

