#Acivate project environment
echo "Info: Begin activate project environment: $ENVIRONMENT_NAME"
eval "$(/opt/anaconda3/bin/conda shell.bash hook)"
conda init
conda activate "${ENVIRONMENT_NAME}"
echo "Info: Current environment: $CONDA_DEFAULT_ENV"

#Go to project folder
cd $PROJECT_PATH

echo "Info: Project path is: $PROJECT_PATH"
echo "Info: Current path is: $PWD"

#Run all founded predict scripts (*.py) in root folder
if find . -maxdepth 1 -name "*.py" -printf '.' | wc -m > 0; 
then
    echo "Info: Founded next python files for predict test: "
    find . -maxdepth 1 -name "*.py"
    echo "Info: Predict test is started ..."
    for f in *.py; 
    do
        echo "Info: Begin test predict file $f ..."
        python $f || exit 1
        echo "Info: successfully tested predict file ${f}!"
    done
    echo "Info: Predict test finished succesfully!"
fi
