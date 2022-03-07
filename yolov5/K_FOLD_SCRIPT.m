% fileList = dir('*.jpg');
fprintf("Select Path for source images\n")
[path_image]=uigetdir;
fprintf("Select Path for source labels files\n")
[path_label]=uigetdir;
fileList_image = dir(fullfile(path_image,'*.jpg'));
fileList_label = dir(fullfile(path_label,'*.txt'));
n = length(fileList_image);
k=input('Insert number of folds\n')
%k = 5;
c = cvpartition(n,'KFold',k);
n_train = floor((1-(1/k))*n);
perc=input('Insert percentage of training split (0.x)\n')
%perc = 0.7;

train = training(c,1);
fprintf("Select Path for split dataset (has to be into yolov5 main folder\n")
base_path=uigetdir;
%base_path='C:\Users\109008\Documents\apprendistato\YOLO\MATLAB\dataset_new';

for i = 1:k

    folder_train_image = fullfile(base_path,strcat('train',num2str(i)),'images');
    mkdir (folder_train_image)

    folder_train_label = fullfile(base_path,strcat('train',num2str(i)),'labels');
    mkdir (folder_train_label)
    

    folder_test_image = fullfile(base_path,strcat('test',num2str(i)),'images');
    mkdir (folder_test_image)

    folder_test_label = fullfile(base_path,strcat('test',num2str(i)),'labels');
    mkdir (folder_test_label)

    folder_val_image = fullfile(base_path,strcat('val',num2str(i)),'images');
    mkdir (folder_val_image)

    folder_val_label = fullfile(base_path,strcat('val',num2str(i)),'labels');
    mkdir (folder_val_label)



    train(:,i) = training(c,i);
    h = 1;
    for j = 1:n
        if train(j,i)==1
            
            if h < floor(n_train*perc)
                copyfile(fullfile(fileList_image(j).folder,fileList_image(j).name),fullfile(folder_train_image,fileList_image(j).name))
                copyfile(fullfile(fileList_label(j).folder,fileList_label(j).name),fullfile(folder_train_label,fileList_label(j).name))

            else
                copyfile(fullfile(fileList_image(j).folder,fileList_image(j).name),fullfile(folder_val_image,fileList_image(j).name))
                copyfile(fullfile(fileList_label(j).folder,fileList_label(j).name),fullfile(folder_val_label,fileList_label(j).name))
            
            end
            h = h + 1; 
        else
            copyfile(fullfile(fileList_image(j).folder,fileList_image(j).name),fullfile(folder_test_image,fileList_image(j).name))
            copyfile(fullfile(fileList_label(j).folder,fileList_label(j).name),fullfile(folder_test_label,fileList_label(j).name))
        end
    end
end

data_fold=(strfind(base_path,'\'));
data_folder=base_path(data_fold(2)+1:end)
fprintf("Select yolov5 folder\n")
yolo_folder=uigetdir()


for i = 1:k
    fid = fopen(fullfile(yolo_folder,strcat('data',num2str(i),'.yaml')), 'w');
    formatSpec = "train:\n ./%s/train%d/images\nval:\n ./%s/val%d/images\n\nnc: 1\nnames: ['0']"
    fprintf(fid, formatSpec, data_folder,i,data_folder,i);
    fclose(fid);
end





