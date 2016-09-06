% wavresample_test.m

Fs_new = 195312.5;

file_path = 'C:\TytoLogy\Experiments\Opto';
file_name = 'P100_11.wav';

[S_new, t_new, Fs_orig, t_orig, S_orig] = ...
							wavresample(fullfile(file_path, file_name), Fs_new);
						
						
						
plot(t_orig, S_orig, '.:', t_new, S_new, '.r')
