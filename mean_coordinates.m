% written by HO (5/1/2018)

% calculate the mean coordinates from each fiducial marker
% clustering 4 fiducial markers using K-means clustering

% ind: number of fiducial markers visible in t1_mprage

% output: paddle.tag including 3 (x,y,z) coordinates
% 1: center of the TMS coil
% 2,3: two other fiducial marker coordinates generating the triangle
% surface

% clc; clear; close all

function mean_coordinates(ind)

if ind == 4
    load xyz_coordinates.tag
    X = xyz_coordinates(:, 1:3);
    [numInst, numDims] = size(X);
    
    % K-means clustering
    % K: number of clusters, G: assigned groups, C: cluster centers
    K = 4;
    [G, C] = kmeans(X, K, 'Distance','cityblock','Replicates',5,'MaxIter', 10);
    
%     % show points and clusters (color-coded) (option)
%     clr = lines(K);
%     figure, hold on
%     scatter3(X(:,1), X(:,2), X(:,3), 36, clr(G,:), 'Marker','.')
%     scatter3(C(:,1), C(:,2), C(:,3), 100, clr, 'Marker','o', 'LineWidth',3)
%     hold off
%     view(3), axis vis3d, box on, rotate3d on
%     xlabel('x'), ylabel('y'), zlabel('z')
    
    center = mean(C);
    
    coor1 = C(1,:); coor2 = C(2,:); coor3 = C(3,:); coor4 = C(4,:);
    % calculate the distance between the center and each coordinate
    dist1 = norm(center - coor1);
    dist2 = norm(center - coor2);
    dist3 = norm(center - coor3);
    dist4 = norm(center - coor4);
    
    % compare the distance and make the final markers' coordinate
    if abs(dist1 - dist2) > 10
        final_xyz = [center; coor1; coor2];
    else
        final_xyz = [center; coor1; coor3];
    end
    
    % save 3 (x,y,z) coordinates into paddle.tag (ascii file)
    filename = 'paddle.tag';
    save(filename, 'final_xyz', '-ascii');
    
% option when only 3 markers in t1-mprage are visible
elseif ind == 3
    load xyz_coordinates.tag
    
    X = xyz_coordinates(:, 1:3);
    [numInst, numDims] = size(X);
    
    % K-means clustering
    % K: number of clusters, G: assigned groups, C: cluster centers
    K = 3;
    [G, C] = kmeans(X, K, 'Distance','cityblock','Replicates',5,'MaxIter', 10);
    
%     % show points and clusters (color-coded) (option)
%     clr = lines(K);
%     figure, hold on
%     scatter3(X(:,1), X(:,2), X(:,3), 36, clr(G,:), 'Marker','.')
%     scatter3(C(:,1), C(:,2), C(:,3), 100, clr, 'Marker','o', 'LineWidth',3)
%     hold off
%     view(3), axis vis3d, box on, rotate3d on
%     xlabel('x'), ylabel('y'), zlabel('z')
    
    coor1 = C(1,:); coor2 = C(2,:); coor3 = C(3,:);
    
    dist1 = norm(coor1 - coor2); dist2 = norm(coor1 - coor3); dist3 = norm(coor2 - coor3);
    
    [min_dist, min_ind] = min([dist1, dist2, dist3]);
    
    if min_ind == 1
        center = mean([coor1; coor2]);
        final_xyz = [center; coor1; coor3];
    elseif min_ind == 2
        center = mean([coor1; coor3]);
        final_xyz = [center; coor1; coor2];
    elseif min_ind == 3
        center = mean([coor2; coor3]);
        final_xyz = [center; coor1; coor2];
    end
    
    filename = 'paddle.tag';
    save(filename, 'final_xyz', '-ascii');
    
end
end