


create ~/.m2/settings.xml with this content
```xml
<settings>
    <profiles>

        <profile>
            <id>sbforge-nexus</id>

            <!--Enable snapshots for the built in central repo to direct -->
            <!--all requests to nexus via the mirror -->
            <repositories>
                <repository>
                    <id>sbforge-nexus</id>
                    <url>https://sbforge.org/nexus/content/groups/public</url>
                    <releases>
                        <enabled>true</enabled>
                    </releases>
                    <snapshots>
                        <enabled>true</enabled>
                    </snapshots>
                </repository>
            </repositories>
            <pluginRepositories>
                <pluginRepository>
                    <id>sbforge-nexus</id>
                    <url>https://sbforge.org/nexus/content/groups/public</url>
                    <releases>
                        <enabled>true</enabled>
                    </releases>
                    <snapshots>
                        <enabled>true</enabled>
                    </snapshots>
                </pluginRepository>
            </pluginRepositories>

	    </profile>

    </profiles>

    <activeProfiles>
        <!--make the profile active all the time -->
        <activeProfile>sbforge-nexus</activeProfile>
    </activeProfiles>

</settings>
```

Install dependencies

```bash
dnf install -y maven cmake gcc gcc-c++ openssl-devel
```

Checkout the source
```bash
mkdir -p ~/projects
cd ~/projects
git clone  git@github.com:apache/hadoop.git
cd hadoop
git checkout branch-3.2.2
```


Build the module 
```bash
cd ~/projects/hadoop/hadoop-yarn-project/hadoop-yarn/hadoop-yarn-server/hadoop-yarn-server-nodemanager
mvn -Pnative -Psbforge-nexus -DskipTests=true clean package
```

The working container-executor can now be found as `~/projects/hadoop/hadoop-yarn-project/hadoop-yarn/hadoop-yarn-server/hadoop-yarn-server-nodemanager/target/native/target/usr/local/bin/container-executor`