try:
    f=open('/.owtf/db.cfg','r')
    a=f.readlines()
    b=[]
    for line in a:
        if line.find('IP')!=-1:
            line='DATABASE_IP: 127.0.0.1\n'
            b.append(line)
        elif line.find('PORT')!=-1:
            line='DATABASE_PORT: 5432\n'
            b.append(line)
        else:
            b.append(line)
    f.close()
    o=open('/.owtf/db.cfg','w')
    o.writelines(b)
    o.close()
except:
    f=open('/root/.owtf/db.cfg','r')
    a=f.readlines()
    b=[]
    for line in a:
        if line.find('IP')!=-1:
            line='DATABASE_IP: 127.0.0.1\n'
            b.append(line)
        elif line.find('PORT')!=-1:
            line='DATABASE_PORT: 5432\n'
            b.append(line)
        else:
            b.append(line)
    f.close()
    o=open('/root/.owtf/db.cfg','w')
    o.writelines(b)
    o.close()
