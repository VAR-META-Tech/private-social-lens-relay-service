import {
  Body,
  Controller,
  HttpCode,
  HttpStatus,
  Post,
  UseGuards,
} from '@nestjs/common';
import {
  ApiHeader,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import { ApiKeyGuard } from '../auth/api-key.guard';
import { EncryptChatDto, EncryptChatResponseDto } from './dto';
import { NautilusService } from './nautilus.service';

@ApiTags('Nautilus Relay')
@Controller('relay/nautilus-tee')
@UseGuards(ApiKeyGuard)
@ApiHeader({
  name: 'x-api-key',
  required: true,
  description: 'API Key for authentication',
})
export class NautilusController {
  constructor(private readonly nautilusService: NautilusService) {}

  @Post('encrypt')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Encrypt raw chat data using Nautilus TEE',
    description:
      'Encrypts Telegram chat data using Nautilus Trusted Execution Environment for secure processing',
  })
  @ApiOkResponse({
    description: 'Successfully encrypted chat data',
    type: EncryptChatResponseDto,
  })
  async encryptChats(
    @Body() body: EncryptChatDto,
  ): Promise<EncryptChatResponseDto> {
    try {
      const encryptedData = await this.nautilusService.encryptData(
        body.telegramChats,
      );

      return {
        success: true,
        encryptedData,
        message: 'Chats encrypted successfully',
      };
    } catch (error) {
      return {
        success: false,
        error: error.message,
        message: 'Failed to encrypt chats',
      };
    }
  }
}
