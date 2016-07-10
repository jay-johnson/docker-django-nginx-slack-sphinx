#!/bin/bash

log="/tmp/deploy.log"

echo "     - To debug the deploy-docs.sh script run: tail -f $log"

echo "$(date +'%m-%d-%y %H:%M:%S') Starting Deployment" > $log

# Extend detection when not running on ose
export PATH_TO_WSGI_DIR="$ENV_BASE_REPO_DIR"

if [ ! -d "$PATH_TO_WSGI_DIR" ]; then
    export PATH_TO_WSGI_DIR="/opt/containerfiles/django/"
fi

export DJANGO_PROJECT_DIR=$PATH_TO_WSGI_DIR/wsgi/server/webapp
export ENV_DOC_SOURCE_DIR=$DJANGO_PROJECT_DIR/docs
export ENV_DOC_OUTPUT_DIR=$DJANGO_PROJECT_DIR/templates

basedomain="http://$ENV_BASE_DOMAIN"
sitemap="$DJANGO_PROJECT_DIR/sitemap.xml"
robotstxt="$DJANGO_PROJECT_DIR/robots.txt"
searchtoolsfile="$PATH_TO_WSGI_DIR/wsgi/static/searchtools.js"

GA_CODE="$ENV_GOOGLE_ANALYTICS_CODE"
echo "$(date +'%m-%d-%y %H:%M:%S') Installing GA Code($GA_CODE)" >> $log
sed -i "s|GOOGLE_ANALYTICS_CODE|$GA_CODE|g" $ENV_DOC_SOURCE_DIR/_templates/layout.html

echo "$(date +'%m-%d-%y %H:%M:%S') Starting Sphinx Build from Source($DJANGO_PROJECT_DIR/docs/) and generating HTML Output($DJANGO_PROJECT_DIR/templates)" >> $log
python /usr/bin/sphinx-build -b html $DJANGO_PROJECT_DIR/docs/ $DJANGO_PROJECT_DIR/templates &>> $log

echo "$(date +'%m-%d-%y %H:%M:%S') Deploying Images" >> $log
if [ -d "$DJANGO_PROJECT_DIR/templates/_images" ]; then
    cp -r $DJANGO_PROJECT_DIR/templates/_images/* $PATH_TO_WSGI_DIR/wsgi/static/_images/ &>> $log
    cp -r $DJANGO_PROJECT_DIR/templates/_images/* $ENV_STATIC_OUTPUT_DIR/_images/ &>> $log
fi

echo "$(date +'%m-%d-%y %H:%M:%S') Deploying Sources" >> $log
cp -r $DJANGO_PROJECT_DIR/templates/_sources  $PATH_TO_WSGI_DIR/wsgi/static/ &>> $log
cp -r $DJANGO_PROJECT_DIR/templates/_sources  $ENV_STATIC_OUTPUT_DIR/ &>> $log

if [ -e $DJANGO_PROJECT_DIR/templates/_downloads ]; then
    echo "$(date +'%m-%d-%y %H:%M:%S') Deploying Downloads" >> $log
    cp -r $DJANGO_PROJECT_DIR/templates/_downloads $PATH_TO_WSGI_DIR/wsgi/static/ &>> $log
    cp -r $DJANGO_PROJECT_DIR/templates/_downloads $ENV_STATIC_OUTPUT_DIR/ &>> $log
fi

echo "$(date +'%m-%d-%y %H:%M:%S') Deploying Statics" >> $log
cp -r $DJANGO_PROJECT_DIR/templates/_static/* $PATH_TO_WSGI_DIR/wsgi/static/ &>> $log
cp -r $DJANGO_PROJECT_DIR/templates/_static/* $ENV_STATIC_OUTPUT_DIR/ &>> $log

# Allow for post start actions like installing SEO per page
echo "$(date +'%m-%d-%y %H:%M:%S') Installing SEO Metadata" >> $log

sourcedir=`echo $ENV_DOC_SOURCE_DIR | sed -e 's|=| |g' | awk '{print $NF}'`
outputdir=`echo $ENV_DOC_OUTPUT_DIR | sed -e 's|=| |g' | awk '{print $NF}'`

echo "$(date +'%m-%d-%y %H:%M:%S') Sources($sourcedir) Outputs($outputdir)" >> $log
pushd $outputdir >> /dev/null

# Walkthrough each html file then find the corresponding rst file (if it exists)
# and extract the SEO_META_ field values that should be included inside a comment 
# section within the rst file and inject the value into the html file
htmlfiles=`ls *.html`
for html in $htmlfiles; do

    if [ "$html" != "genindex.html" ] && [ "$html" != "search.html" ]; then
    
        rstfile=`echo $html | sed -e 's|\.html|\.rst|g'`
        rst="$sourcedir/$rstfile"

        if [ -e "$rst" ]; then
            echo "$(date +'%m-%d-%y %H:%M:%S') Processing($html) RST($rst)" >> $log
            set_list=`cat $html | grep SEO_META_ | sed -e 's|="| |g' | sed -e 's|"||g' | sed -e "s|\/>||g" | sed -e 's|>||g' | awk '{print $NF}'`
            for setval in $set_list; do
                rstval=`cat $rst | grep $setval | sed -e "s|$setval=\"| |g" | sed "s|^[ \t]*||" | sed -e 's|"||g' | sed -e "s|\/>||g" | sed -e 's|>||g'`
                echo "$(date +'%m-%d-%y %H:%M:%S') - HTMLKey($setval) RSTVal($rstval)" >> $log
                if [ "$rstval" != "" ]; then
                    sed -i "s|$setval|$rstval|g" $html
                fi
            done
        fi
    else
        sed -i "s|SEO_META_URL|http://YOUR_SITE|g" $html
        sed -i "s|SEO_META_TITLE|Sample Title Page|g" $html
        sed -i "s|SEO_META_DESC|Sample Page Description|g" $html
        sed -i "s|SEO_META_KEYWORD|software, docker, django, slack, sphinx|g" $html
        sed -i "s|SEO_META_CREATOR|@YOUR-TWITTER-NAME|g" $html
        sed -i "s|SEO_META_TYPE|website|g" $html
        sed -i "s|SEO_META_ALSO|http://YOUR_SITE|g" $html
        sed -i "s|SEO_META_IMAGE|/static/_images/image_logo.png|g" $html
        sed -i "s|SEO_META_AUTHOR|YOUR NAME|g" $html
    fi

    sed -i 's|src="_static|src="/static|g' $html
    sed -i 's|href="_static|href="/static|g' $html
    sed -i 's|href="_images|href="/static/_images|g' $html
    sed -i 's|href="_sources|href="/static/_sources|g' $html
    sed -i 's|href="_downloads|href="/static/_downloads|g' $html
done

popd >> /dev/null

echo "$(date +'%m-%d-%y %H:%M:%S') Done Installing SEO Metadata" >> $log

# Create the sitemap:
echo "$(date +'%m-%d-%y %H:%M:%S') Building sitemap.xml for BaseDomain($ENV_BASE_DOMAIN) Path($sitemap)" >> $log
echo '<?xml version="1.0" encoding="UTF-8"?>' > $sitemap
echo '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"' >> $sitemap
echo '        xmlns:mobile="http://www.google.com/schemas/sitemap-mobile/1.0"' >> $sitemap
echo '        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ' >> $sitemap
echo '        xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">' >> $sitemap

# Process rst files in the docs directory:
siteentries=`ls $ENV_DOC_SOURCE_DIR/*.rst | sed -e 's|/| |g' | awk '{print $NF}' | sed -e 's|rst|html|g'`
for entry in $siteentries; do
    siteurl="$basedomain/docs/$entry"
    echo "$(date +'%m-%d-%y %H:%M:%S') Adding Entry($entry) with full SiteURL($siteurl)" >> $log
    echo "   <url>" >> $sitemap
    echo "      <loc>$siteurl</loc>" >> $sitemap
    echo "   </url>" >> $sitemap
done

# Process url entries in the urls.py file:
apiurls=`cat $DJANGO_PROJECT_DIR/urls.py | grep "url(" | grep 'api.' | grep -v webapi | grep -v docs | grep -v internal_ | awk '{print $1}' | sed -e "s|url(r'\^||g" | sed -e "s|',| |g" | awk '{print $1}'`
for entry in $apiurls; do
    siteurl="$basedomain/$entry"
    echo "$(date +'%m-%d-%y %H:%M:%S') Adding API Entry($entry) with full SiteURL($siteurl)" >> $log
    echo "   <url>" >> $sitemap
    echo "      <loc>$siteurl</loc>" >> $sitemap
    echo "   </url>" >> $sitemap
done

echo "</urlset>" >> $sitemap

chmod 666 $sitemap >> $log

echo "$(date +'%m-%d-%y %H:%M:%S') Done Creating Sitemap($sitemap)" >> $log

# Create the robots.txt file:
echo "$(date +'%m-%d-%y %H:%M:%S') Creating Robots($robotstxt)" >> $log
echo "User-agent: *" > $robotstxt
echo "Disallow: /static/" >> $robotstxt
chmod 666 $robotstxt >> $log
echo "$(date +'%m-%d-%y %H:%M:%S') Done Creating Robots($robotstxt)" >> $log

# Patch the searchtools file:
echo "$(date +'%m-%d-%y %H:%M:%S') Patching SearchTools for Nested URL($searchtoolsfile)" >> $log
sed -i "s|$.get(DOCUMENTATION_OPTIONS.URL_ROOT + '_sources/' +|$.get(DOCUMENTATION_OPTIONS.URL_ROOT + '../_sources/' +|g" $searchtoolsfile
echo "$(date +'%m-%d-%y %H:%M:%S') Done Patching SearchTools for Nested URL($searchtoolsfile)" >> $log

exit 0
