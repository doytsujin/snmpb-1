#ifndef DISCOVERY_H
#define DISCOVERY_H

#include "snmpb.h"

class Discovery: public QObject
{
    Q_OBJECT
    
public:
    Discovery(Snmpb *snmpb);
    
protected slots:
    void Discover(void);

private:
    Snmpb *s;
};

#endif /* DISCOVERY_H */

