CREATE OR REPLACE PACKAGE SP_GETYJHHX IS

  PROCEDURE SF_GETHHX(PI_YPTBDM  IN varchar2,
                      lx         IN varchar2,
                      y1         out number,
                      y2         out number,
                      y3         out number,
                      y4         out number,
                      r1         out number,
                      ydy1         out number,
                      ydr1         out number,
                      ydr2         out number,
                      PO_RETCODE OUT NUMBER, --���ش���
                      PO_ERRMSG  OUT VARCHAR2);

END;
/
create or replace package body SP_GETYJHHX is

  PROCEDURE SF_GETHHX(PI_YPTBDM  IN varchar2,
                      lx         IN varchar2,
                      y1         out number,
                      y2         out number,
                      y3         out number,
                      y4         out number,
                      r1         out number,
                      ydy1         out number,
                      ydr1         out number,
                      ydr2         out number,
                      PO_RETCODE OUT NUMBER, --���ش���
                      PO_ERRMSG  OUT VARCHAR2) is
    nstep   number;
    v_ypfl  varchar2(100);
    v_sfxsq varchar2(1);
    v_hl    varchar2(200);
  
  begin
    PO_RETCODE := 1;
    nstep      := 1;
    select case
             when gzyj like '��ȱҩƷ%' then
              '��ȱҩƷ'
             when nvl(substr(trim(b.yptsbz), 15, 1), 0) = '1' or
                  nvl(substr(trim(b.yptsbz), 16, 1), 0) = '1' then
              'ԭ��ҩƷ/�α��Ƽ�'
             when gzyj like 'ͨ������%' then
              'ͨ������'
             when gzyj like 'ҽ��ҩƷ%' then
              'ҽ��ҩƷ'
             when gzyj like '����ҽ��%' then
              '����ҽ��'
             when gzyj like '����ҩƷ%' then
              '����ҩƷ'
             else
              null
           end,
           case
             when gzyj like '%������%' then
              '1'
             else
              '0'
           end,
           case
             when nvl(trim(substrb(b.zxdwhl, 1, 10)), 0) <> '0' and nvl(trim(substrb(b.zxdwhl, 1, 10)), 0) <> '0.0' then
              trim(substrb(b.zxdwhl, 1, 10))
             when nvl(trim(substrb(b.zxdwhl, 31, 10)), 0) <> '0' and nvl(trim(substrb(b.zxdwhl, 31, 10)), 0) <> '0.0' then
              trim(substrb(b.zxdwhl, 31, 10))
             else
              '1'
           end 
      into v_ypfl, v_sfxsq, v_hl 
      from tb_ypcggz_fbk a, v_yppg_fbk b
     where a.yptbdm = b.yptbdm
       and a.yptbdm = PI_YPTBDM;
  if lx='YY' then 
    nstep := 2;
  
    --����1  ԭ�ɹ��ۣ���۹���
    --20200302cjl:����03��������ҩƷȥ������1
    --20200902cjl:������ҩƷȥ������1
    --20210419:����05ҩƷ����1ȡֵΪ��۹���
  
    select max(case
             when v_sfxsq = '1'   then
              null
             when b.bz like  '%����05%' then to_number(nvl(d.gzcsz, yjjg))
             else
              nvl(a.jg, yjjg)
           end)
      into y1
      from tb_yellowline1 a, tb_ypscyjjg c,tb_ypwjgz_fbk b,tb_ypwjgz_bdkmx d
     where a.yptbdm(+)=b.yptbdm and b.yptbdm = c.yptbdm(+) 
       and b.YPWJBDID=d.ypwjbdid and gzlx='10'
       and a.yxbz(+)='1' and a.jsrq(+)>to_char(sysdate,'yyyyMMdd')
       and c.yxbz(+) = '1'
       and b.yptbdm = PI_YPTBDM;
    --����2  �������ͬƷ��
    nstep := 3;
  

    select case
         when v_ypfl = 'ԭ��ҩƷ/�α��Ƽ�' then
          round(max(to_number(case when  b.YPFBSJID in ('1','2') then null 
                                --   when d.gzyj like  '%������%' then null 
                                   when b.bz like  '%����01%' then null 
                                   when b.bz like  '%����03%' then null
                                   when nvl(substrb(a.yptsbz, 15, 1), 0) = '1' or 
                                      nvl(substrb(a.yptsbz, 16, 1), 0) = '1' 
                                           then nvl(case when b.bz like  '%����05%' then to_number(g.gzcsz) else c.jg end,e.yjjg) end) *--20210419����05����۹�����Ϊȡֵ��Դ
                    sf_getcbjbyyp(PI_YPTBDM, v_hl) /
                    sf_getcbjbyyp(a.yptbdm, v_hl)),
                2) --ԭ�в�ѯȫ��ҩƷ����������⣩20210413��ԭ��ҩƷ��ѯԭ��ҩƷ�������벻���⣩
         else
          nvl(round(max(case
                          when nvl(substrb(a.yptsbz, 15, 1), 0) = '1' or
                               nvl(substrb(a.yptsbz, 16, 1), 0) = '1' then
                           null
                          when lengthb(a.zxdwhl) < 51 then
                           null
                          when  b.YPFBSJID in ('1','2') then 
                           null
                          when d.gzyj like  '%������%' then 
                           null
                          when b.bz like  '%����01%' then null 
                          when b.bz like  '%����03%' then null 
                          when b.bz like  '%����05%' then to_number(nvl(g.gzcsz ,e.yjjg)) --20210419����05����۹�����Ϊȡֵ��Դ
                          else
                           to_number(nvl(c.jg ,e.yjjg))
                        end * sf_getcbjbyyp(PI_YPTBDM, v_hl) /
                        sf_getcbjbyyp(a.yptbdm, v_hl)),
                    2), --��ԭ�в�ѯ��ԭ�е�ҩƷ����������⣩
              round(max(case
                          when nvl(substrb(a.yptsbz, 15, 1), 0) = '1' or
                               nvl(substrb(a.yptsbz, 16, 1), 0) = '1' then
                           null
                          when lengthb(a.zxdwhl) < 51 then
                           null
                          when  b.YPFBSJID in ('1','2') then 
                           null
                          when b.bz like  '%����01%' then null 
                          when b.bz like  '%����03%' then null
                          when b.bz like  '%����05%' then to_number(nvl(g.gzcsz, e.yjjg))--20210419����05����۹�����Ϊȡֵ��Դ
                          else
                           to_number(nvl(c.jg, e.yjjg))
                        end * sf_getcbjbyyp(PI_YPTBDM, v_hl) /
                        sf_getcbjbyyp(a.yptbdm, v_hl)),
                    2) --���ԭ�У��������� ��߼�Ϊ�յĻ����Ͱ���������ҩƷ
              )
       end
       into y2
  from tb_yppg_fbk     t1,
       v_ybbm_mlsxh    t2,
       tb_yppg_fbk     a,
       tb_ypwjgz_fbk   b,
       tb_yellowline1 c,
       tb_ypcggz_fbk   d,
       tb_ypscyjjg     e,
       v_ybbm_mlsxh    f,
       tb_ypwjgz_bdkmx g
 where t1.YPCPMWBM=a.ypcpmwbm --20210408��Ŀ¼�����Ϊ�껯ͨ������ѯ
   and t1.yptbdm = t2.yptbdm
   and t2.sjmlsxh = f.sjmlsxh--20210419:ͬĿ¼˳���
   and t2.zxybz = f.zxybz 
   and a.yptbdm = b.yptbdm
   and b.YPWJBDID=g.ypwjbdid
   and g.gzlx='10' 
   and a.yptbdm = d.yptbdm
   and a.yptbdm = e.yptbdm(+)
   and a.yptbdm = c.yptbdm(+)
   and a.yptbdm = f.yptbdm 
   and c.yxbz(+)='1' 
   and c.jsrq(+)>to_char(sysdate,'yyyyMMdd')
   and d.jczbzt <> '0'
   and e.yxbz(+) <>'0'
   and t1.yptbdm = PI_YPTBDM;

    --����1  ԭ�к���
    nstep := 4;
    if v_ypfl <> 'ԭ��ҩƷ/�α��Ƽ�' then
    select   max(case
                             when lengthb(a.ZXDWHL) < 51 then
                              null
                             when  e.YPFBSJID in ('1','2') then 
                              null
                             when e.bz like  '%����01%' then null 
                             when e.bz like  '%����03%' then null
                             when e.bz like  '%����05%' then to_number(nvl(h.gzcsz, decode(g.yjjg,0,null,g.yjjg)))--20210419����05����۹�����Ϊȡֵ��Դ
                             else
                              to_number(nvl(f.jg, decode(g.yjjg,0,null,g.yjjg)))
                           end * sf_getcbjbyyp(PI_YPTBDM, v_hl) /
                           sf_getcbjbyyp(a.yptbdm, v_hl)) 
      into r1
      from tb_yppg_fbk     t1,
           v_ybbm_mlsxh   t2,
           tb_yppg_fbk     a,
           v_ybbm_mlsxh   b,
           tb_ypcggz_fbk   d,
           tb_ypwjgz_fbk   e,
           tb_yellowline1 f,
           tb_ypscyjjg     g,
           tb_ypwjgz_bdkmx h
     where t1.yptbdm = t2.yptbdm
       and a.yptbdm = b.yptbdm
       and a.yptbdm = d.yptbdm
       and a.yptbdm = e.yptbdm
       and e.YPWJBDID=h.ypwjbdid
       and h.gzlx='10'
       and a.yptbdm = g.yptbdm(+)
       and a.yptbdm = f.yptbdm(+)
       and f.yxbz(+) = '1'
       and f.jsrq(+) > to_char(sysdate,'yyyyMMdd')
       and d.jczbzt <> '0'
       and g.yxbz(+) <> '0'
       and t2.sjmlsxh = b.sjmlsxh
       and t2.zxybz = b.zxybz 
       and (nvl(substr(trim(a.yptsbz), 15, 1), 0) = '1' or
           nvl(substr(trim(a.yptsbz), 16, 1), 0) = '1')
       and t1.yptbdm = PI_YPTBDM;
       
       --����3=����*0.7
       y3:=round(r1*0.7,2);
       --������������
       r1:=round(r1,2);
     end if;
    --����4  ����Ʒ��
    nstep := 6;
      select round(case when v_sfxsq='1' or v_ypfl = 'ͨ������' then  --20210402��������߹���ҩƷ����4ȡ����Ϊһ��
      max(case
                          when lengthb(g.ZXDWHL) < 51 then
                           0
                          when  d.YPFBSJID in ('1','2') then 
                           0
                          when d.bz like  '%����01%' then 0 
                          when d.bz like  '%����03%' then 0 
                          when h.gzyj like '%������%' then--20200803������ҩƷΪ������ҩƷ��ȡʵʱ�����ͼ�
                           (select min(cgjg)
                              from tb_yjjgbb
                             where yptbdm = a.cfgg
                               and zt = '20' and yxbz='1'
                               and to_char(sysdate, 'yyyyMMdd') between ksrq and jsrq)
                          else
                           to_number(nvl(decode(a.cgjg,0,null,a.cgjg), f.yjjg))--20210402�۸���Ŀ¼����ֱ��ά��
                        end * sf_getcbjbyyp(PI_YPTBDM, v_hl) /
                        sf_getcbjbyyp(a.cfgg, v_hl)) 
                        else  null end ,2)
        into y4
        from v_ybbm_mlsxh   t1,
             tb_yppg_fbk     t2,
             tb_ypmlk        a,
             v_ybbm_mlsxh   b,
             tb_ypwjgz_fbk   d,
             tb_ypscyjjg     f,
             tb_yppg_fbk     g,
             tb_ypcggz_fbk   h
       where a.cfgg = b.yptbdm
         and a.cfgg = d.yptbdm
         and a.cfgg = g.yptbdm
         and a.cfgg = h.yptbdm
         and a.cfgg = f.yptbdm(+)
         and t1.sjmlsxh = b.sjmlsxh
         and t1.zxybz = b.zxybz
         and t1.YPTBDM = t2.yptbdm
         and f.yxbz(+) = '1'
         and a.ypmllx = '06'
         and a.yxbz='1'
         and t1.yptbdm = PI_YPTBDM;

else 
  --ҩ�����1����ҩƷ��ҽ�ƻ�����߲ɹ��۰���ȼ����������ۼۡ�
    nstep := 7;
    select  
           max(t.cgjg)   
       into ydr1
  from  
       (select nvl(nvl(m1.yptbdm,m2.yptbdm),m3.yptbdm) yptbdm,nvl(nvl(m1.cgjg,m2.cgjg),m3.cgjg) cgjg
       from tb_yyzgcgj m1, tb_yyzgcgj m2,tb_yyzgcgj m3
       where m3.yptbdm=m1.yptbdm(+) and m3.yptbdm=m2.yptbdm(+)
       and m1.yxbz(+)='1' and m2.yxbz(+)='1' AND M3.YXBZ='1' 
       and m1.yxq(+)=3 and m2.yxq(+)=6 and m3.yxq=0
       and to_char(sysdate,'yyyyMMdd') between m3.ksrq and m3.jsrq 
       and to_char(sysdate,'yyyyMMdd') between m1.ksrq(+) and m1.jsrq(+) 
       and to_char(sysdate,'yyyyMMdd') between m2.ksrq(+) and m2.jsrq(+) ) t
 where   t.yptbdm = PI_YPTBDM;
    
    --ҩ�����2������ҵͬƷ�֣�mlsxh��ҩƷ��ԭ�вαȳ��⣩ҽ�ƻ�����߲ɹ��۰���ȼ����������ۼۡ�
    nstep := 8;
    select   case
         when v_ypfl = 'ԭ��ҩƷ/�α��Ƽ�' then--ԭ��ֻ��ԭ��
          max(case when nvl(substrb(a.yptsbz, 15, 1), 0) = '1' or 
                                      nvl(substrb(a.yptsbz, 16, 1), 0) = '1' then d.cgjg end * 
                    sf_getcbjbyyp(PI_YPTBDM, v_hl) /
                    sf_getcbjbyyp(a.yptbdm, v_hl))   
         else --��ͨ����ͨ
           max(case when nvl(substrb(a.yptsbz, 15, 1), 0) = '1' or 
                                      nvl(substrb(a.yptsbz, 16, 1), 0) = '1' then null else  d.cgjg end * 
                    sf_getcbjbyyp(PI_YPTBDM, v_hl) /
                    sf_getcbjbyyp(a.yptbdm, v_hl))   end
           
        
       into ydr2
  from v_yppg_fbk     t1,
       v_ybbm_mlsxh    t2,
       v_yppg_fbk     a,  
       v_ybbm_mlsxh    c ,
       (select nvl(nvl(m1.yptbdm,m2.yptbdm),m3.yptbdm) yptbdm,nvl(nvl(m1.cgjg,m2.cgjg),m3.cgjg) cgjg
       from tb_yyzgcgj m1, tb_yyzgcgj m2,tb_yyzgcgj m3
       where m3.yptbdm=m1.yptbdm(+) and m3.yptbdm=m2.yptbdm(+)
       and m1.yxbz(+)='1' and m2.yxbz(+)='1' and m3.yxbz='1'
       and m1.yxq(+)=3 and m2.yxq(+)=6 and m3.yxq=0
       and to_char(sysdate,'yyyyMMdd') between m3.ksrq and m3.jsrq 
       and to_char(sysdate,'yyyyMMdd') between m1.ksrq(+) and m1.jsrq(+) 
       and to_char(sysdate,'yyyyMMdd') between m2.ksrq(+) and m2.jsrq(+)) d
 where trim(upper(to_single_byte(t1.scqymc)))=trim(upper(to_single_byte(a.scqymc))) 
   and t1.yptbdm = t2.yptbdm
   and a.yptbdm=c.yptbdm
   and t2.sjmlsxh = c.sjmlsxh 
   and t2.zxybz = c.zxybz 
   and a.yptbdm=d.yptbdm(+) 
   and t1.yptbdm = PI_YPTBDM;
    --ҩ����ߣ�ͬͨ����ҩƷ(ԭ�вαȳ���)��ҽ�ƻ�������߲ɹ��۰���ȼ����������ۼ�
    nstep := 9;
     select  case
         when v_ypfl = 'ԭ��ҩƷ/�α��Ƽ�' then--ԭ��ֻ��ԭ��
           max(case when nvl(substrb(a.yptsbz, 15, 1), 0) = '1' or 
                                      nvl(substrb(a.yptsbz, 16, 1), 0) = '1' then d.cgjg end  * 
                    sf_getcbjbyyp(PI_YPTBDM, v_hl) /
                    sf_getcbjbyyp(a.yptbdm, v_hl))  
          else --��ͨ����ͨ
            max(case when nvl(substrb(a.yptsbz, 15, 1), 0) = '1' or 
                                      nvl(substrb(a.yptsbz, 16, 1), 0) = '1' then null else  d.cgjg end   * 
                    sf_getcbjbyyp(PI_YPTBDM, v_hl) /
                    sf_getcbjbyyp(a.yptbdm, v_hl))  end
        
       into ydy1
  from v_yppg_fbk     t1, 
       v_yppg_fbk     a,   
       (select nvl(nvl(m1.yptbdm,m2.yptbdm),m3.yptbdm) yptbdm,nvl(nvl(m1.cgjg,m2.cgjg),m3.cgjg) cgjg
       from tb_yyzgcgj m1, tb_yyzgcgj m2,tb_yyzgcgj m3
       where m3.yptbdm=m1.yptbdm(+) and m3.yptbdm=m2.yptbdm(+)
       and m1.yxbz(+)='1' and m2.yxbz(+)='1' and m3.yxbz='1'
       and m1.yxq(+)=3 and m2.yxq(+)=6 and m3.yxq=0
       and to_char(sysdate,'yyyyMMdd') between m3.ksrq and m3.jsrq 
       and to_char(sysdate,'yyyyMMdd') between m1.ksrq(+) and m1.jsrq(+) 
       and to_char(sysdate,'yyyyMMdd') between m2.ksrq(+) and m2.jsrq(+)) d
 where t1.ypcpmwbm=a.ypcpmwbm 
   and a.yptbdm=d.yptbdm(+) 
   and t1.yptbdm = PI_YPTBDM;
      
      select case
               when ydr1 >= 500 then
                round(ydr1,2) + 75
               when ydr1 < 500 then
                round(ydr1 * 1.15,2)
             end,
             case
               when ydr2 >= 500 then
                round(ydr2,2) + 75
               when ydr2 < 500 then
                round(ydr2 * 1.15,2)
             end,
             case
               when ydy1 >= 500 then
                round(ydy1,2) + 75
               when ydy1 < 500 then
                round(ydy1 * 1.15,2)
             end
             
        into ydr1, ydr2,ydy1
        from dual;
      end if;

  EXCEPTION
    WHEN OTHERS THEN
      PO_RETCODE := 2;
      PO_ERRMSG  := nstep || '������ִ���,��������Ϊ:' || SQLERRM;
    
  end;

end SP_GETYJHHX;
/
