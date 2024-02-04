function savefileList = EdgeExtraction(RECT, GLTlat, GLTlon, mark, year,results_dir)
%创建shp文件存储路径
savePath = ([results_dir,'\shp']);
if ~exist(savePath, 'dir')
    mkdir(savePath);
end
savefileList = strings(1, size(RECT, 3));
for ti = 1:size(RECT, 3)
    savefile = ([savePath, '\', year, 'SHP', num2str(mark), '_T', num2str(ti), '.shp']);
    savefileList(ti) = savefile;
    if ~exist(savefile, 'file')
        %     temp=double(edge(RECT(:,:,ti),'sobel'));
        %     temp(temp==0)=0.5;
        %     RECT(:,:,ti)=temp;
        bw = im2bw(RECT(:, :, ti), 0.5); %阈值分割
        if mark ~= 3
            bw1 = bwareaopen(bw, 10); %删除面积小于10的区域
            bw2 = imfill(bw1, 'holes'); %填充孔洞
            %         figure,imshow(bw2);
            bw3 = bwboundaries(bw2); %得到边缘轮廓，一个轮廓为一个line
        else
            bw2 = imfill(bw, 'holes'); %填充孔洞
            %         figure,imshow(bw2);
            bw3 = bwboundaries(bw2); %得到边缘轮廓，一个轮廓为一个line
        end
        num = size(bw3, 1); %行数
        SRT = 'struct("Geometry",values,"X",values,"Y",values,"ID",values)';
        values = cell(num, 1); %为结构体赋初值
        s = eval(SRT);
        clear values;
        for i = 1:num
            data = bw3{i, 1}; %得到轮廓线的坐标，一个N*2的矩阵，此坐标为本地图像坐标
            S(i).Geometry = 'Line';
            S(i).ID = i;
            %将本地图像坐标准换为地理坐标
            x = GLTlat(data(:, 1), 1);
            y = GLTlon(1, data(:, 2))';
            S(i).X = [x; NaN]';
            S(i).Y = [y; NaN]';
        end
        %         figure,axis off;
        %         mapshow([S.X], [S.Y],'Color','r');  %绘制轮廓线
        shapewrite(S, savefile);
    end
end
