#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <ctype.h>

#include "voiceCmdExe.h"

#define BUFFER_SIZE 1024
#define on_error(...) { fprintf(stderr, __VA_ARGS__); fflush(stderr); exit(1); }

static int press_number_key(char num)
{
    char cmdString [64];
    sprintf(cmdString, "debugsh -c phone key %d", 513 + (num - '0')); 
    printf("%s\n", cmdString);
    system(cmdString);
    return 0;
}

static int press_back_key(void)
{
    system("debugsh -c phone key 525");
    return 0;
}

static int press_speaker_key(void)
{
    system("debugsh -c phone key 553");
    return 0;
}

static int press_release_key(void)
{
    system("debugsh -c phone key 555");
    return 0;
}

static int press_contacts_key(void)
{
    system("debugsh -c phone key 550");
    return 0;
}

static int press_nav_down(void)
{
    system("debugsh -c phone key 546");
    return 0;
}

static int press_soft_key(int keycode)
{
    char cmdString [64];
    sprintf(cmdString, "debugsh -c phone key %d", 525 + keycode); 
 
    printf("%s\n", cmdString);
    system(cmdString);
    return 0;
}

static int press_abc_key(char abc)
{
    if (isupper(abc)) abc = tolower(abc);
    switch (abc) {
        case 'a': case 'b': case 'c':
	    for(int i = 0; i <= abc - 'a'; i++) {
                press_number_key('2');
	    }
	break;
        case 'd': case 'e': case 'f':
	    for(int i = 0; i <= abc - 'd'; i++) {
                press_number_key('3');
	    }
	break;
        case 'g': case 'h': case 'i':
	    for(int i = 0; i <= abc - 'g'; i++) {
                press_number_key('4');
	    }
	break;
        case 'j': case 'k': case 'l':
	    for(int i = 0; i <= abc - 'j'; i++) {
                press_number_key('5');
	    }
	break;
        case 'm': case 'n': case 'o':
	    for(int i = 0; i <= abc - 'm'; i++) {
                press_number_key('6');
	    }
	break;
	case 'p': case 'q': case 'r': case 's':
	    for(int i = 0; i <= abc - 'p'; i++) {
                press_number_key('7');
	    }
	break;
        case 't': case 'u': case 'v':
	    for(int i = 0; i <= abc - 't'; i++) {
                press_number_key('8');
	    }
	break;
	case 'w': case 'x': case 'y': case 'z':
	    for(int i = 0; i <= abc - 'w'; i++) {
                press_number_key('9');
	    }
	break;
	default:
            on_error("Error: Not in Alphabet ! \n");
	break;
    }
    return 0;
}
// Dial 4242
// Dial Xiaolin Huang
// Call Xiaolin Huang
// Hold Call
// Resume Call
// End Call

static int exeVoiceCmd(const char *cmd)
{
   char *pCmd;
   char *voiceCmd[10] = {0};
   char cmdBuf[BUFFER_SIZE];
   short cmdWordCnt = 0;

   if ( cmd == NULL ||
        strlen(cmd) > BUFFER_SIZE - 1 ||
	strlen(cmd) <= 0 ) {
       on_error("Invalid command !\n");
       return -1;
   }
   
   memset(cmdBuf, '\0', BUFFER_SIZE); 
   memcpy(cmdBuf, cmd, strlen(cmd));
   
   // extract commands: [command] [keycode]
   pCmd = strtok(cmdBuf, " "); // space as delimiter
   while (pCmd != NULL) {
       voiceCmd[cmdWordCnt] = malloc(strlen(pCmd) + 1);
       memset(voiceCmd[cmdWordCnt], '\0', strlen(pCmd) + 1);
       memcpy(voiceCmd[cmdWordCnt], pCmd, strlen(pCmd) + 1);
       ++cmdWordCnt;
       //printf("%s len: %d\n", pCmd, strlen(pCmd));
       pCmd = strtok(NULL, " "); // space as delimiter
   }
   
   if (cmdWordCnt < 1) {
       on_error("No call number or name !");
       return -1; 
   }

   if (!strcmp(voiceCmd[0], "Dial") || !strcmp(voiceCmd[0], "Call")) {
        // Dial [Name] or Dial [Number]
        // Call [Name] or Call [Number]
       press_back_key();
       press_back_key();
       if ( voiceCmd[1][0] >= '0' && voiceCmd[1][0] <= '9' ) {
           int i = 0;
           //offhook
           press_speaker_key();
           for (; i < strlen(voiceCmd[1]); i++) {
               press_number_key(voiceCmd[1][i]);
           }
       } else {  //Alphabet: search directory and dial out
           // search name in company directory
           press_contacts_key();
           press_number_key('2'); // enter Corporate Directory
           sleep(2);
           for (int i = 1; i < cmdWordCnt; i++) {
               printf("Name string: %s \n", voiceCmd[i]);
               for (int j = 0; j < strlen(voiceCmd[i]); j++) {
                   press_abc_key(voiceCmd[i][j]);
                   usleep(750000);  // key bubble last timer
	       }
               press_nav_down();
           }
           // submit input
           press_soft_key(2);
           sleep(2);
           // we'd better to check if we got the right result.
	   // dial out
           press_soft_key(2);
       }
       
   } else if (!strcmp(voiceCmd[0], "End")) {
        // End Call 
       press_release_key();
   } else {
       printf("**** WARNING ! unsupported command ! ****\n");
   }

   // clean up    
   for(int i = 0; i < cmdWordCnt; i++) {
       if (voiceCmd[i]) {
           free(voiceCmd[i]);
	   voiceCmd[i] = NULL;
       }
   }
 
   return 0; 
}

int main (int argc, char *argv[]) {
  if (argc < 2) on_error("Usage: %s [port]\n", argv[0]);

  int port = atoi(argv[1]);

  int server_fd, client_fd, err;
  struct sockaddr_in server, client;
  char buf[BUFFER_SIZE];
  char addr_buf[INET_ADDRSTRLEN];

  memset(buf, '\0', BUFFER_SIZE);
  server_fd = socket(AF_INET, SOCK_STREAM, 0);
  if (server_fd < 0) on_error("Could not create socket\n");

  server.sin_family = AF_INET;
  server.sin_port = htons(port);
  server.sin_addr.s_addr = htonl(INADDR_ANY);

  int opt_val = 1;
  setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR, &opt_val, sizeof opt_val);

  err = bind(server_fd, (struct sockaddr *) &server, sizeof(server));
  if (err < 0) on_error("Could not bind socket\n");

  err = listen(server_fd, 128);
  if (err < 0) on_error("Could not listen on socket\n");

  printf("Server is listening on %d\n", port);

  while (1) {
    socklen_t client_len = sizeof(client);
    client_fd = accept(server_fd, (struct sockaddr *) &client, &client_len);
    printf("connection from %s, port %d\n",
            inet_ntop(AF_INET, &client.sin_addr, addr_buf, sizeof(addr_buf)),
            ntohs(client.sin_port));

    if (client_fd < 0) on_error("Could not establish new connection\n");

    while (1) {
      int read = recv(client_fd, buf, BUFFER_SIZE, 0);

      if (!read) break; // done reading
      if (read < 0) on_error("Client read failed\n");
      
      printf("Receiving msg: %s \n", buf);
      
      exeVoiceCmd(buf);

      err = send(client_fd, buf, read, 0);
      if (err < 0) on_error("Client write failed\n");
      memset(buf, '\0', BUFFER_SIZE);
    }
  }

  return 0;
}

