node {
    
    // Setup the Docker Registry (Docker Hub) + Credentials 
    env.REGISTRY_URL = "https://index.docker.io/v1/" // Docker Hub
    env.DOCKER_CREDS_ID = "jayjohnson-DockerHub" // name of the Jenkins Credentials ID
    env.BUILD_TAG = "testing" // default tag to push for to the registry
    
    stage 'Checking out GitHub Repo'
    git url: 'https://github.com/jay-johnson/docker-django-nginx-slack-sphinx.git'
    
    stage 'Building Django Container for Docker Hub'
    docker.withRegistry("${env.REGISTRY_URL}", "${env.DOCKER_CREDS_ID}") {
    
        // Set up the container to build 
        env.MAINTAINER_NAME = "jayjohnson"
        env.CONTAINER_NAME = "django-slack-sphinx"
        
        stage "Building"
        
        def container = docker.build("${env.MAINTAINER_NAME}/${env.CONTAINER_NAME}:${env.BUILD_TAG}", 'django')
        sh "echo ${container.imageName()} -- ${container.id}"
        
        // Taken from the Dockerfile Environment Variables:
        // https://github.com/jay-johnson/docker-django-nginx-slack-sphinx/blob/ee7c1901e7708de5d801518fb765fe79c18e690d/django/Dockerfile#L40-L60
        env.ENV_BASE_HOMEDIR = "/opt"
        env.ENV_BASE_REPO_DIR = "/opt/containerfiles/django"
        env.ENV_BASE_DATA_DIR = "/opt/containerfiles/django/data"
        env.ENV_DEFAULT_ROOT_VOLUME = "/opt/web"
        env.ENV_DOC_SOURCE_DIR = "/opt/web/django/blog/source"
        env.ENV_DOC_OUTPUT_DIR = "/opt/web/django/templates"
        env.ENV_STATIC_OUTPUT_DIR = "/opt/web/static"
        env.ENV_MEDIA_DIR = "/opt/web/media"
        env.ENV_BASE_DOMAIN = "jaypjohnson.com"
        env.ENV_SLACK_BOTNAME = "bugbot"
        env.ENV_SLACK_CHANNEL = "debugging"
        env.ENV_SLACK_NOTIFY_USER = "jay"
        env.ENV_SLACK_TOKEN = "xoxb-51351043345-Lzwmto5IMVb8UK36MghZYMEi"
        env.ENV_SLACK_ENVNAME = "djangoapp"
        env.ENV_GOOGLE_ANALYTICS_CODE = "UA-79840762-99"
        env.ENV_DJANGO_DEBUG_MODE = "True"
        env.ENV_SERVER_MODE = "DEV"
        env.ENV_DEFAULT_PORT = "80"
        env.ENV_PROJ_DIR = "/opt/containerfiles/django/wsgi/server/webapp"
    
        try {
        
            stage "Testing Django container"
            echo "-e ENV_BASE_DOMAIN=${env.ENV_BASE_DOMAIN} -e ENV_GOOGLE_ANALYTICS_CODE=${env.ENV_GOOGLE_ANALYTICS_CODE} -e ENV_DJANGO_DEBUG_MODE=${env.ENV_DJANGO_DEBUG_MODE} -e ENV_SERVER_MODE=${env.ENV_SERVER_MODE} -e ENV_DEFAULT_PORT=${env.ENV_DEFAULT_PORT} -e ENV_BASE_HOMEDIR=${env.ENV_BASE_HOMEDIR} -e ENV_BASE_REPO_DIR=${env.ENV_BASE_REPO_DIR} -e ENV_BASE_DATA_DIR=${env.ENV_BASE_DATA_DIR} -v ${env.ENV_DEFAULT_ROOT_VOLUME}:${env.ENV_DEFAULT_ROOT_VOLUME} -v ${env.ENV_DOC_SOURCE_DIR}:${env.ENV_DOC_SOURCE_DIR} -v ${env.ENV_DOC_OUTPUT_DIR}:${env.ENV_DOC_OUTPUT_DIR} -v ${env.ENV_STATIC_OUTPUT_DIR}:${env.ENV_STATIC_OUTPUT_DIR} -v ${env.ENV_MEDIA_DIR}:${env.ENV_MEDIA_DIR} -p 82:80 -p 444:443"
            docker.image("jayjohnson/${env.CONTAINER_NAME}:${env.BUILD_TAG}").withRun("--name=${env.CONTAINER_NAME} -e ENV_BASE_DOMAIN=${env.ENV_BASE_DOMAIN} -e ENV_GOOGLE_ANALYTICS_CODE=${env.ENV_GOOGLE_ANALYTICS_CODE} -e ENV_DJANGO_DEBUG_MODE=${env.ENV_DJANGO_DEBUG_MODE} -e ENV_SERVER_MODE=${env.ENV_SERVER_MODE} -e ENV_DEFAULT_PORT=${env.ENV_DEFAULT_PORT} -e ENV_BASE_HOMEDIR=${env.ENV_BASE_HOMEDIR} -e ENV_BASE_REPO_DIR=${env.ENV_BASE_REPO_DIR} -e ENV_BASE_DATA_DIR=${env.ENV_BASE_DATA_DIR} -v ${env.ENV_DEFAULT_ROOT_VOLUME}:${env.ENV_DEFAULT_ROOT_VOLUME} -v ${env.ENV_DOC_SOURCE_DIR}:${env.ENV_DOC_SOURCE_DIR} -v ${env.ENV_DOC_OUTPUT_DIR}:${env.ENV_DOC_OUTPUT_DIR} -v ${env.ENV_STATIC_OUTPUT_DIR}:${env.ENV_STATIC_OUTPUT_DIR} -v ${env.ENV_MEDIA_DIR}:${env.ENV_MEDIA_DIR} -p 82:80 -p 444:443")  { c ->
                
                // wait for the django server to be ready for testing
                // probably a better way to cut down a couple seconds by ssh into 
                // the container
                sh "sleep 5"
                
                echo "Checking Docker Container is running"
                sh "docker ps | grep ${env.CONTAINER_NAME}"
                    
                // for this demo it is using 3 tests:
                def MAX_TESTS = 3
                for (test_num = 0; test_num < MAX_TESTS; test_num++) {     
                   
                    echo "Running Test(${test_num})"
                
                    expected_results = 0
                    if (test_num == 0 ) 
                    {
                        // Test we can download the home page from the running django docker container
                        sh "docker exec -t ${env.CONTAINER_NAME} curl -s http://localhost/home/ | grep Welcome | wc -l | tr -d '\n' > /tmp/test_results" 
                        expected_results = 1
                    }
                    else if (test_num == 1)
                    {
                        // Test that port 80 is exposed
                        echo "Exposed Docker Ports:"
                        sh "docker inspect --format '{{ (.NetworkSettings.Ports) }}' ${env.CONTAINER_NAME}"
                        sh "docker inspect --format '{{ (.NetworkSettings.Ports) }}' ${env.CONTAINER_NAME} | grep map | grep '80/tcp:' | wc -l | tr -d '\n' > /tmp/test_results"
                        expected_results = 1
                    }
                    else if (test_num == 2)
                    {
                        // Test there's nothing established on the port since nginx is not running:
                        sh "docker exec -t ${env.CONTAINER_NAME} netstat -apn | grep 80 | grep ESTABLISHED | wc -l | tr -d '\n' > /tmp/test_results"
                        expected_results = 0
                    }
                    else
                    {
                        err_msg = "Missing Test(${test_num})"
                        echo "ERROR: ${err_msg}"
                        echo "ERROR: ${err_msg}"
                        echo "ERROR: ${err_msg}"
                        currentBuild.result = 'FAILURE'
                        FORCE_GROOVY_TO_FAIL_RIGHT_HERE_WITH_AN_EXCEPTION
                    }
                    
                    // Now validate the results
                    stage "Test(${test_num}) - Validate Results"
                    test_results = readFile '/tmp/test_results'
                    echo "Test(${test_num}) Results($test_results) == Expected(${expected_results})"
                    sh "if [ \"${test_results}\" != \"${expected_results}\" ]; then echo \" --------------------- Test(${test_num}) Failed--------------------\"; echo \" - Test(${test_num}) Failed\"; echo \" - Test(${test_num}) Failed\";exit 1; else echo \" - Test(${test_num}) Passed\"; exit 0; fi"
                    sh "docker exec -t ${env.CONTAINER_NAME} curl -s http://localhost/home/ | grep Welcome"
                    echo "Done Running Test(${test_num})"
                
                    // cleanup after the test run
                    sh "rm -f /tmp/test_results"
                    currentBuild.result = 'SUCCESS'
                }
            }
            
        } catch (Exception err) {
            def err_msg = "Test had Exception(${err})"
            echo "FAILED - Stopping for Error: ${err_msg}"
            currentBuild.result = 'FAILURE'
            sh "exit 1"
        }
        
        stage "Pushing"
        container.push()
        
        currentBuild.result = 'SUCCESS'
    }
    
    stage 'Building nginx Container for Docker Hub'
    docker.withRegistry("${env.REGISTRY_URL}", "${env.DOCKER_CREDS_ID}") {
        
        // Set up the container to build
        env.MAINTAINER_NAME = "jayjohnson"
        env.CONTAINER_NAME = "django-nginx"
        env.BUILD_TAG = "testing"
     
        stage "Building Container"
         
        def container = docker.build("${env.MAINTAINER_NAME}/${env.CONTAINER_NAME}:${env.BUILD_TAG}", 'nginx')
       
        // add more tests
        
        stage "Pushing"
        container.push()
        
        currentBuild.result = 'SUCCESS'
    }
    
    currentBuild.result = 'SUCCESS'
    
    ///////////////////////////////////////
    //
    // Coming Soon Feature Enhancements
    //
    // 1. Add Docker Compose testing as a new Pipeline item that is initiated after this one for "Integration" testing
    // 2. Make sure to set the Pipeline's "Throttle builds" to 1 because the docker containers will collide on resources like ports and names
    // 3. Should be able to parallelize the docker.withRegistry() methods to ensure the container is running on the slave
    // 4. After the tests finish (and before they start), clean up container images to prevent stale docker image builds from affecting the current test run
}
