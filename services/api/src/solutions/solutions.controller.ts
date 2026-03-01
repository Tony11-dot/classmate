import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CurrentUser } from '../auth/current-user.decorator';
import { SolutionsService } from './solutions.service';
import { CreateSolutionDto } from './dto/create-solution.dto';
import { UpdateSolutionDto } from './dto/update-solution.dto';
import { AddSolutionImageDto } from './dto/add-solution-image.dto';

@UseGuards(JwtAuthGuard)
@Controller('solutions')
export class SolutionsController {
  constructor(private readonly solutions: SolutionsService) {}

  @Post()
  create(@CurrentUser() user: any, @Body() dto: CreateSolutionDto) {
    return this.solutions.create(user, dto);
  }

  @Get()
  list(@CurrentUser() user: any, @Query() q: any) {
    return this.solutions.list(user, q);
  }

  @Get(':id')
  get(@Param('id') id: string) {
    return this.solutions.get(id);
  }

  @Patch(':id')
  update(
    @CurrentUser() user: any,
    @Param('id') id: string,
    @Body() dto: UpdateSolutionDto,
  ) {
    return this.solutions.update(user, id, dto);
  }

  @Delete(':id')
  remove(@CurrentUser() user: any, @Param('id') id: string) {
    return this.solutions.remove(user, id);
  }

  @Post(':id/images')
  addImage(
    @CurrentUser() user: any,
    @Param('id') id: string,
    @Body() dto: AddSolutionImageDto,
  ) {
    return this.solutions.addImage(user, id, dto);
  }

  @Delete('images/:imageId')
  deleteImage(@CurrentUser() user: any, @Param('imageId') imageId: string) {
    return this.solutions.deleteImage(user, imageId);
  }

  @Post(':id/like')
  like(@CurrentUser() user: any, @Param('id') id: string) {
    return this.solutions.like(user, id);
  }

  @Delete(':id/like')
  unlike(@CurrentUser() user: any, @Param('id') id: string) {
    return this.solutions.unlike(user, id);
  }

  @Get(':id/comments')
  listComments(@Param('id') id: string, @Query() q: any) {
    return this.solutions.listComments(id, q);
  }

  @Post(':id/comments')
  addComment(@CurrentUser() user: any, @Param('id') id: string, @Body() dto: any) {
    return this.solutions.addComment(user, id, dto);
  }
}

