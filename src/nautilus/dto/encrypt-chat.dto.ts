import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString } from 'class-validator';

export class EncryptChatDto {
  @ApiProperty({
    description: 'Raw Telegram chat data in string format',
    example: 'Raw chat data here...',
  })
  @IsString()
  @IsNotEmpty()
  telegramChats: string;
}

export class EncryptedDataDto {
  @ApiProperty({
    description: 'Nonce used for encryption',
    example: 'nonce_string_here',
  })
  nonce: string;

  @ApiProperty({
    description: 'Encrypted ciphertext',
    example: 'ciphertext_string_here',
  })
  ciphertext: string;

  @ApiProperty({
    description: 'Authentication tag',
    example: 'tag_string_here',
  })
  tag: string;
}

export class EncryptChatResponseDto {
  @ApiProperty({
    description: 'Operation success status',
    example: true,
  })
  success: boolean;

  @ApiProperty({
    description: 'Encrypted chat data object',
    type: EncryptedDataDto,
    required: false,
  })
  encryptedData?: EncryptedDataDto;

  @ApiProperty({
    description: 'Response message',
    example: 'Chats encrypted successfully',
  })
  message: string;

  @ApiProperty({
    description: 'Error message if operation failed',
    required: false,
    nullable: true,
  })
  error?: string;
}
