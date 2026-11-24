function [fncase,flcase,fnctrl,flctrl] = bmsubj_fil(cols,cols_ctrl);
%BMSUBJ_FIL Reads Biomarkers study MRI spreadsheet, 
%         Biomark_MRI_StudyKey.xls, and returns a cell array of valid
%         knee ID numbers for case injured knees (in column 1) and
%         uninjured contralateral knees (in column 2) and control
%         baseline injured knees (in column 1), and follow-up injured
%         knees (in column 2) and uninjured contralateral knees (in
%         column 3).
%
%         FNCASE = BMSUBJ_FIL returns cell array, FNCASE, of valid case
%         knee ID numbers.  Only complete sets of knee MRI IDs are
%         returned in the two (2) column cell array.
%
%         [FNCASE,FLCASE] = BMSUBJ_FIL returns logical matrix, FLCASE,
%         with logical flags for the case pairs of MRI knees.  See
%         note #3 below.
%
%         [FNCASE,FLCASE,FNCTRL] = BMSUBJ_FIL returns cell array,
%         FNCTRL, of valid control knee ID numbers.  Only complete sets
%         of knee MRI IDs are returned in the three (3) column cell
%         array.
%
%         [FNCASE,FLCASE,FNCTRL,FLCTRL] = BMSUBJ_FIL returns logical
%         matrix, FLCTRL, with logical flags for the control pairs of
%         MRI knees.  See note #3 below.
%
%         FNCASE = BMSUBJ_FIL(COLS) returns valid knee ID numbers with
%         valid defined by the columns in the logical flags matrices,
%         FLCASE for case and FLCTRL for control knees, based on the
%         columns in the index row vector COLS.  By default, valid is
%         defined as column 7 (complete set of MRIs).
%
%         [FNCASE,FLCASE,FNCTRL,FLCTRL] = BMSUBJ_FIL(COLS,COLS_CTRL)
%         returns valid knee ID numbers with valid defined by the 
%         columns in the logical flags matrices, FLCASE for case and
%         FLCTRL for control knees, based on the columns in the index
%         row vectors, COLS for cases and COLS_CTRL for controls.  Note
%         control knees have two additional columns of flags for
%         baseline and follow-up MRIs.  See spreadsheet for details.
%
%         NOTES:  1.  The columns of the cell array FNCASE of valid
%                 knee ID numbers contain injured knees in column 1 and 
%                 uninjured contralateral knees in column 2.  The knee
%                 IDs are cell arrays of character arrays.
%
%                 2.  The columns of the cell array FNCTRL of valid
%                 knee ID numbers contain control baseline injured
%                 knees in column 1, and follow-up injured knees in
%                 column 2 and uninjured contralateral knees in column
%                 3.  The knee IDs are cell arrays of character arrays.
%
%                 3.  The columns of the logical flag matrices FLCASE
%                 and FLCTRL are:
%                 Column 1:  Sex = 0 - female, = 1 - male
%                 Column 2:  Case/Control = 0 - control, = 1 - case
%                 Column 3:  Post/Pre Surgery = 0 - pre-surgical MRI,
%                 = 1 - post-surgical MRI
%                 Column 4:  1st/2nd = 0 - 1st time injury (valid), = 1
%                 - other (more than one injury)
%                 Column 5:  Tibia Aspect Ratio (AR) = 0 - AR >= 1, 
%                 = 1 - AR < 1
%                 Column 6:  Femur Aspect Ratio (AR) = 0 - AR >= 1, 
%                 = 1 - AR < 1
%                 Column 7:  Incomplete = 0 - complete set of scans,
%                 = 1 - incomplete (missing a scan)  (For control knees
%                 both baseline and follow-up scans must be complete.)
%                 Column 8:  Baseline MRI = 0 - complete set of
%                 baseline scans, = 1 - incomplete baseline (missing a
%                 baseline scan)  (Control knees only.)
%                 Column 9:  Follow-up MRI = 0 - complete set of
%                 follow-up scans, = 1 - incomplete follow-up (missing
%                 a scan)  (Control knees only.)
%
%                 4.  Note that only "valid" sets of MRI knee ID numbers
%                 are returned.  The columns used to determine "valid"
%                 sets can be input.  "valid" is defined as not true
%                 (false) flags.
%
%                 5.  Spreadsheet Biomark_MRI_StudyKey.xls must be in
%                 the current directory.
%
%         20-Aug-2014 * Mack Gardner-Morse
%

%#######################################################################
%
% Check for Inputs
%
if (nargin<1)||isempty(cols)
  cols = 7;
end
%
cols = cols(:)';
if islogical(cols)
  cols = find(cols);
end
%
if (nargin<2)||isempty(cols_ctrl)
  cols_ctrl = cols;
end
%
cols_ctrl = cols_ctrl(:)';
if islogical(cols_ctrl)
  cols_ctrl = find(cols_ctrl);
end
%
% Read Spreadsheet
%
[num1,txt1,raw1] = xlsread('Biomark_MRI_StudyKey.xls','Case');
[num2,txt2,raw2] = xlsread('Biomark_MRI_StudyKey.xls','Control');
%
% Get Flags for Study Sets of MRIs
%
nr1 = size(txt1,1);     % Number of case rows
nr2 = size(txt2,1);     % Number of control rows
%
idx1 = (5:nr1)';        % Row index (skip first four rows) for cases
idx2 = (5:nr2)';        % Row index (skip first four rows) for controls
iflag1 = [4:10];        % Column index for case flags
iflag2 = [5:13];        % Column index for control flags
flcase = logical(cell2mat(raw1(idx1,iflag1)));   % Case flags
flctrl = logical(cell2mat(raw2(idx2,iflag2)));   % Control flags
%
% Get "Valid" Sets
%
id1 = find(cols<=7);
col1 = cols(id1);
idv1 = flcase(:,col1);
idv1 = ~any(idv1,2);    % Index to valid case rows (sets of MRIs)
%
id2 = find(cols_ctrl<=9);
col2 = cols_ctrl(id2);
idv2 = flctrl(:,col2);
idv2 = ~any(idv2,2);    % Index to valid control rows (sets of MRIs)
%
% Get Sets of Knee ID Numbers
%
fncase = raw1(idx1(idv1),2:3);         % Valid case knee IDs
flcase = flcase(idv1,:);               % Valid case knee flags
%
fnctrl = raw2(idx2(idv2),2:4);         % Valid control knee IDs
flctrl = flctrl(idv2,:);               % Valid control knee flags
%
return