#Find project environment
echo "Info: Begin find environment file ..."
ENVIRONMENT_FILE=$(find . -name "[^.]*.yml" | head -n 1)
echo "Info: Found environment file: ${ENVIRONMENT_FILE}"

EXISTS_FILE=$(echo $ENVIRONMENT_FILE | wc -w)
if [[ "$EXISTS_ENV" == "0" ]]; 
then
    "Erorr: Can not deploy project without environment file (*.yml) ..."
    exit 1
fi

echo "Info: Begin find project environment name ..."
ENVIRONMENT_NAME=$(find . -wholename "$ENVIRONMENT_FILE" -exec basename {} .yml ";")
ENVIRONMENT_NAME="ci_${CI_PROJECT_NAME}_${ENVIRONMENT_NAME}"
echo "Info: Project environment found: $ENVIRONMENT_NAME"

#Add to PATH variable conda path
PATH="/opt/anaconda3/bin:/opt/anaconda3/condabin:${PATH}"

#Save PATH and ENVIRONMENT_NAME variavle for passing to another job
echo "Info: Begin saving variable ENVIRONMENT_NAME to file ..."
echo "PATH=${PATH}" >> buildenv.env || exit 1 
echo "ENVIRONMENT_NAME=${ENVIRONMENT_NAME}" >> buildenv.env || exit 1 
echo "Info: Variable ENVIRONMENT_NAME successfully saved to file ..."

#Create environment with delete existing if needed
echo "Info: Begin processing environment: ${ENVIRONMENT_NAME} ..."
EXISTS_ENV=$(conda env list | grep "${ENVIRONMENT_NAME}" | wc -l)
if [[ $EXISTS_ENV == "1" ]]; 
then
    echo "Info: Environment ${ENVIRONMENT_NAME} exists!"                    
    echo "Info: Begin remove existing environment: ${ENVIRONMENT_NAME} ..."
    conda env remove --name $ENVIRONMENT_NAME || exit 1 
    echo "Inf: Existing environment ${ENVIRONMENT_NAME} removed succesfully!"    
fi

echo "Info: Begin create environment: ${ENVIRONMENT_NAME} ..."
conda env create --name $ENVIRONMENT_NAME --file $ENVIRONMENT_FILE || exit 1
conda clean -a
echo "Info: Environment: ${ENVIRONMENT_NAME} created successfully!"

echo "Info: End processing file with environment: $f!"



