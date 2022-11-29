ORIGINAL_PATH=$(pwd)
TEST_PATH="${PROJECT_PATH}tests/"                       #path for folder with tests    

#Acivate project environment
echo "Info: Begin activate project environment: $ENVIRONMENT_NAME"
eval "$(/opt/anaconda3/bin/conda shell.bash hook)"
conda init
conda activate "${ENVIRONMENT_NAME}"
echo "Info: Current environment: $CONDA_DEFAULT_ENV"


if [ -d "${TEST_PATH}" ]; 
then
    echo "Info: Folder ${TEST_PATH} is found, preparing for unit tests ..."
    cd $TEST_PATH

    if find . -name "test_*.py" -printf '.' | wc -m > 0; 
    then
        echo "Info: Founded next files for unit testing:..."
        find . -name "test_*.py"
        echo "Info: Pytest is started..."
        pytest --junitxml=$ORIGINAL_PATH/report.xml
        echo "Info: Pytest finished succesfully!"
    fi 
       
else
    echo "Warning: Folder ${TEST_PATH} is not exists, nothing to test!"
fi
