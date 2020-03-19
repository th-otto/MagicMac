/*
 * Copyright (c) 1982, 1986 Regents of the University of California.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgement:
 *	This product includes software developed by the University of
 *	California, Berkeley and its contributors.
 * 4. Neither the name of the University nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 *	@(#)ip_icmp.h	8.1 (Berkeley) 6/10/93
 */

/*
 * Interface Control Message Protocol Definitions.
 * Per RFC 792, September 1981.
 */

#ifndef _NETINET_IP_ICMP_H
#define _NETINET_IP_ICMP_H

#ifndef _NETINET_IN_SYSTM_H
# include <netinet/in_systm.h>
#endif

__BEGIN_DECLS

struct icmphdr
{
  uint8_t type;		/* message type */
  uint8_t code;		/* type sub-code */
  uint16_t checksum;
  union
  {
    struct
    {
      uint16_t	id;
      uint16_t	sequence;
    } echo;			/* echo datagram */
    uint32_t	gateway;	/* gateway address */
    struct
    {
      uint16_t	__glibc_reserved;
      uint16_t	mtu;
    } frag;			/* path mtu discovery */
  } un;
};

/*
 * Internal of an ICMP Router Advertisement
 */
struct icmp_ra_addr
{
  uint32_t ira_addr;
  uint32_t ira_preference;
};

/*
 * Structure of an icmp header.
 */
struct icmp {
	u_char	icmp_type;		/* type of message, see below */
	u_char	icmp_code;		/* type sub code */
	u_short	icmp_cksum;		/* ones complement cksum of struct */
	union {
		u_char ih_pptr;			/* ICMP_PARAMPROB */
		struct in_addr ih_gwaddr;	/* ICMP_REDIRECT */
		struct ih_idseq {
			uint16_t	icd_id;
			uint16_t	icd_seq;
		} ih_idseq;
		uint32_t ih_void;

	    /* ICMP_UNREACH_NEEDFRAG -- Path MTU Discovery (RFC1191) */
	    struct ih_pmtu
	    {
	      uint16_t ipm_void;
	      uint16_t ipm_nextmtu;
	    } ih_pmtu;

	    struct ih_rtradv
	    {
	      uint8_t irt_num_addrs;
	      uint8_t irt_wpa;
	      uint16_t irt_lifetime;
	    } ih_rtradv;
	} icmp_hun;
#define	icmp_pptr	icmp_hun.ih_pptr
#define	icmp_gwaddr	icmp_hun.ih_gwaddr
#define	icmp_id		icmp_hun.ih_idseq.icd_id
#define	icmp_seq	icmp_hun.ih_idseq.icd_seq
#define	icmp_void	icmp_hun.ih_void
#define	icmp_pmvoid	icmp_hun.ih_pmtu.ipm_void
#define	icmp_nextmtu	icmp_hun.ih_pmtu.ipm_nextmtu
#define	icmp_num_addrs	icmp_hun.ih_rtradv.irt_num_addrs
#define	icmp_wpa	icmp_hun.ih_rtradv.irt_wpa
#define	icmp_lifetime	icmp_hun.ih_rtradv.irt_lifetime
	union {
		struct id_ts {
			n_time its_otime;
			n_time its_rtime;
			n_time its_ttime;
		} id_ts;
		struct id_ip  {
			struct ip idi_ip;
			/* options and then 64 bits of data */
		} id_ip;
	    struct icmp_ra_addr id_radv;
		u_long	id_mask;
		uint8_t	id_data[1];
	} icmp_dun;
#define	icmp_otime	icmp_dun.id_ts.its_otime
#define	icmp_rtime	icmp_dun.id_ts.its_rtime
#define	icmp_ttime	icmp_dun.id_ts.its_ttime
#define	icmp_ip		icmp_dun.id_ip.idi_ip
#define	icmp_radv	icmp_dun.id_radv
#define	icmp_mask	icmp_dun.id_mask
#define	icmp_data	icmp_dun.id_data
};

/*
 * Lower bounds on packet lengths for various types.
 * For the error advice packets must first insure that the
 * packet is large enough to contain the returned ip header.
 * Only then can we do the check to see if 64 bits of packet
 * data have been returned, since we need to check the returned
 * ip header length.
 */
#define	ICMP_MINLEN	8				/* abs minimum */
#define	ICMP_TSLEN	(8 + 3 * sizeof (n_time))	/* timestamp */
#define	ICMP_MASKLEN	12				/* address mask */
#define	ICMP_ADVLENMIN	(8 + sizeof (struct ip) + 8)	/* min */
#ifndef _IP_VHL
#define	ICMP_ADVLEN(p)	(8 + ((p)->icmp_ip.ip_hl << 2) + 8)
	/* N.B.: must separately check that ip_hl >= 5 */
#else
#define	ICMP_ADVLEN(p)	(8 + (IP_VHL_HL((p)->icmp_ip.ip_vhl) << 2) + 8)
	/* N.B.: must separately check that header length >= 5 */
#endif

/*
 * Definition of type and code field values.
 */
#define	ICMP_ECHOREPLY			0		/* echo reply */
#define	ICMP_DEST_UNREACH		3		/* dest unreachable, codes: */
#define		ICMP_NET_UNREACH		0	/* bad net */
#define		ICMP_HOST_UNREACH		1	/* bad host */
#define		ICMP_PROT_UNREACH		2	/* bad protocol */
#define		ICMP_PORT_UNREACH		3	/* bad port */
#define		ICMP_FRAG_NEEDED		4	/* IP_DF caused drop */
#define		ICMP_SR_FAILED			5	/* src route failed */
#define		ICMP_NET_UNKNOWN		6	/* unknown net */	
#define		ICMP_HOST_UNKNOWN		7	/* unknown host */
#define		ICMP_HOST_ISOLATED		8	/* src host isolated */
#define		ICMP_NET_ANO			9	/* net denied */
#define		ICMP_HOST_ANO			10	/* host denied */
#define		ICMP_NET_UNR_TOS		11	/* bad tos for net */
#define		ICMP_HOST_UNR_TOS		12	/* bad tos for host */
#define		ICMP_PKT_FILTERED		13	/* Packet filtered */
#define		ICMP_PREC_VIOLATION		14	/* Precedence violation */
#define		ICMP_PREC_CUTOFF		15	/* Precedence cut off */
#define		NR_ICMP_UNREACH			15	/* instead of hardcoding immediate value */
#define	ICMP_SOURCE_QUENCH		4		/* packet lost, slow down */
#define	ICMP_REDIRECT			5		/* shorter route, codes: */
#define		ICMP_REDIR_NET			0	/* for network */
#define		ICMP_REDIR_HOST			1	/* for host */
#define		ICMP_REDIR_NETTOS		2	/* for net and tos */
#define		ICMP_REDIR_HOSTTOS		3	/* for host and tos */
#define	ICMP_ECHO				8		/* echo service */
#define	ICMP_ROUTERADVERT		9		/* router advertisement */
#define	ICMP_ROUTERSOLICIT		10		/* router solicitation */
#define	ICMP_TIME_EXCEEDED		11		/* time exceeded, code: */
#define		ICMP_EXC_TTL			0	/* TTL count exceeded */
#define		ICMP_EXC_FRAGTIME		1	/* Fragment Reass time exceeded	*/
#define	ICMP_PARAMETERPROB		12		/* ip header bad */
#define	ICMP_TIMESTAMP			13		/* timestamp request */
#define	ICMP_TIMESTAMPREPLY		14		/* timestamp reply */
#define	ICMP_INFO_REQUEST		15		/* information request */
#define	ICMP_INFO_REPLY			16		/* information reply */
#define	ICMP_ADDRESS			17		/* address mask request */
#define	ICMP_ADDRESSREPLY		18		/* address mask reply */
#define NR_ICMP_TYPES			18


#ifdef __USE_MISC

/* Definition of type and code fields. */
/* defined above: ICMP_ECHOREPLY, ICMP_REDIRECT, ICMP_ECHO */
#define	ICMP_UNREACH		ICMP_DEST_UNREACH
#define	ICMP_SOURCEQUENCH	ICMP_SOURCE_QUENCH
#define	ICMP_TIMXCEED		ICMP_TIME_EXCEEDED
#define	ICMP_PARAMPROB		ICMP_PARAMETERPROB
#define	ICMP_TSTAMP			ICMP_TIMESTAMP
#define	ICMP_TSTAMPREPLY	ICMP_TIMESTAMPREPLY
#define	ICMP_IREQ			ICMP_INFO_REQUEST
#define	ICMP_IREQREPLY		ICMP_INFO_REPLY
#define	ICMP_MASKREQ		ICMP_ADDRESS
#define	ICMP_MASKREPLY		ICMP_ADDRESSREPLY

#define	ICMP_MAXTYPE		NR_ICMP_TYPES

/* UNREACH codes */
#define	ICMP_UNREACH_NET	        	ICMP_NET_UNREACH
#define	ICMP_UNREACH_HOST	        	ICMP_HOST_UNREACH
#define	ICMP_UNREACH_PROTOCOL	    	ICMP_PROT_UNREACH
#define	ICMP_UNREACH_PORT	        	ICMP_PORT_UNREACH
#define	ICMP_UNREACH_NEEDFRAG	    	ICMP_FRAG_NEEDED
#define	ICMP_UNREACH_SRCFAIL	    	ICMP_SR_FAILED
#define	ICMP_UNREACH_NET_UNKNOWN    	ICMP_NET_UNKNOWN
#define	ICMP_UNREACH_HOST_UNKNOWN   	ICMP_HOST_UNKNOWN
#define	ICMP_UNREACH_ISOLATED	    	ICMP_HOST_ISOLATED
#define	ICMP_UNREACH_NET_PROHIB	    	ICMP_NET_ANO
#define	ICMP_UNREACH_HOST_PROHIB    	ICMP_HOST_ANO
#define	ICMP_UNREACH_TOSNET	        	ICMP_NET_UNR_TOS
#define	ICMP_UNREACH_TOSHOST	    	ICMP_HOST_UNR_TOS
#define	ICMP_UNREACH_FILTER_PROHIB  	ICMP_PKT_FILTERED
#define	ICMP_UNREACH_HOST_PRECEDENCE    ICMP_PREC_VIOLATION
#define	ICMP_UNREACH_PRECEDENCE_CUTOFF  ICMP_PREC_CUTOFF

/* REDIRECT codes */
#define	ICMP_REDIRECT_NET		ICMP_REDIR_NET
#define	ICMP_REDIRECT_HOST		ICMP_REDIR_HOST
#define	ICMP_REDIRECT_TOSNET	ICMP_REDIR_NETTOS
#define	ICMP_REDIRECT_TOSHOST	ICMP_REDIR_HOSTTOS

/* TIMEXCEED codes */
#define	ICMP_TIMXCEED_INTRANS	ICMP_EXC_TTL
#define	ICMP_TIMXCEED_REASS		ICMP_EXC_FRAGTIME

/* PARAMPROB code */
#define	ICMP_PARAMPROB_OPTABSENT 1		/* req. opt. absent */

#define	ICMP_INFOTYPE(type) \
	((type) == ICMP_ECHOREPLY || (type) == ICMP_ECHO || \
	(type) == ICMP_ROUTERADVERT || (type) == ICMP_ROUTERSOLICIT || \
	(type) == ICMP_TSTAMP || (type) == ICMP_TSTAMPREPLY || \
	(type) == ICMP_IREQ || (type) == ICMP_IREQREPLY || \
	(type) == ICMP_MASKREQ || (type) == ICMP_MASKREPLY)

#endif /* __USE_MISC */

__END_DECLS

#endif
