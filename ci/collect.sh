PROJECTS_PATH="${HOME}/projects/"                                                   #path where all projects deployed

if [[ "$CI_COMMIT_REF_NAME" == "master" ]]; 
  then PROJECTS_PATH="/opt/ml/projects/";
fi

PROJECT_PATH="${PROJECTS_PATH}${CI_PROJECT_NAME}/"                                  #path for current project
PROJECT_MODELS_PATH="./models"                                                      #path for folder models inside project

echo "Info: Projects path is: $PROJECTS_PATH"
echo "Info: Project path is: $PROJECT_PATH"

SHARE_PATH="/mnt/share/MLShare/Development/${CI_PROJECT_NAME}"                      #path for current project shared files (wich not stored in git)
MODELS_SHARE_PATH="${SHARE_PATH}/models/"                                           #path for folder with models

ARTIFACTS_SHARE_PATH="${HOME}/ci/artifacts/${CI_PROJECT_NAME}"                      #path for local saving artifacts

#Save PROJECT_PATH variavle for passing to another job
echo "Info: Begin saving variable PROJECT_PATH to file ..."
echo "PROJECT_PATH=${PROJECT_PATH}" >> collect.env || exit 1 
echo "Info: Variable PROJECT_PATH successfully saved to file ..."

########################################################################################################
#COPY MODELS FILES (*.PKL) FROM SHARE
########################################################################################################
#Check if folder exists in project, and delete if exists
if [ -d "${PROJECT_MODELS_PATH}" ]; then
  echo "Warning: Folder ${PROJECT_MODELS_PATH} is exists, we will delete it."
  rm -Rf $PROJECT_MODELS_PATH | exit 1
  echo "Warning: Folder ${PROJECT_MODELS_PATH} was successfully removed."
fi

#Check if source folder exists, and give warning if None
if [ ! -d "${MODELS_SHARE_PATH}" ]; then
  echo "Warning: Folder ${MODELS_SHARE_PATH} is not exists, nothing to copy."
fi

#Check if source folder exists and target not, after that copy files from source to target
if [ ! -d "${PROJECT_MODELS_PATH}" ] && [ -d "${MODELS_SHARE_PATH}" ]; then
  echo "Info: Copy files from ${MODELS_SHARE_PATH} to ${PROJECT_MODELS_PATH}"
  cp -R $MODELS_SHARE_PATH $PROJECT_MODELS_PATH  | exit 1
  echo "Info: Files copied succesfully from ${MODELS_SHARE_PATH} to ${PROJECT_MODELS_PATH} "
  echo "Info: Copied files are: "
  ls $PROJECT_MODELS_PATH
fi

########################################################################################################
#COPY CURRENT PROJECT TO PROJECTS LOCATION
########################################################################################################

if [ ! -d "$PROJECTS_PATH" ]; then
  echo "Info: Projects parent folder is not exists: ${PROJECTS_PATH}"
  echo "Info: Begin creating empty parent folder: ${PROJECTS_PATH} ..."
  #mkdir $MODEL_PARENT_PATH | exit 1
  mkdir $PROJECTS_PATH | exit 1
  echo "Info: Successfully created projects parent folder: ${PROJECTS_PATH}"
fi

if [ -d "$PROJECT_PATH" ]; then
  echo "Info: Project folder exists: ${PROJECT_PATH}"
  echo "Info: Begin remove old project folder and all items inside: ${PROJECT_PATH} ..."
  rm -Rf $PROJECT_PATH | exit 1
  echo "Info: Successfully removed old project folder: ${PROJECT_PATH}"
fi

if [ ! -d "$PROJECTS_PATH" ]; then
  echo "Info: Folder ${PROJECTS_PATH} is not exists"
  echo "Info: Creating empty projects folder ${PROJECTS_PATH}..."
  mkdir $PROJECTS_PATH | exit 1
fi

cp -R . $PROJECT_PATH | exit 1

########################################################################################################
#SAVE ARTIFACT FOR VM
########################################################################################################
if [[ "$CI_COMMIT_REF_NAME" == "master" ]]; then
  #chown -R svc_ml:deploy_serve_ml $PROJECTS_PATH
  chgrp -R deploy_serve_ml $PROJECT_PATH
  chmod 770 -R $PROJECT_PATH
fi

########################################################################################################
#SAVE ARTIFACT FOR VM
########################################################################################################
if [[ ! "$CI_COMMIT_REF_NAME"=="master" ]]; then
  tar cf "${ARTIFACTS_SHARE_PATH}.zip" . | exit 1
  echo "Info: Artifacts saved to ${ARTIFACTS_SHARE_PATH}.zip"
fi  
#cp -R . $ARTIFACTS_SHARE_PATH

