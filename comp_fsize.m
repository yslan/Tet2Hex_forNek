function [osize,otype]=comp_fsize(fname)

s=dir(fname); filesize=s.bytes; [osize,otype]=conv_bytes(filesize,'bytes');
